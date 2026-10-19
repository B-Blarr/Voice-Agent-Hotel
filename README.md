# Voice Agent Hotel

**Nina** is the AI receptionist of *Hotel Elmblick*, a fictional family-run
hotel in Schöningen, Lower Saxony. She answers the phone in German, answers
questions about rooms, prices, breakfast, arrival and house rules, and takes
callback requests for the team when a question needs a human.

The conversation runs on **ElevenLabs Agents**. When Nina decides a callback
is needed, she calls a webhook tool on my own server, where an **n8n**
workflow validates the request and stores it in **PostgreSQL**. Everything on
the server runs in **Docker** behind **Nginx** on a Hostinger VPS.

> **Status:** Nina works end to end in the ElevenLabs browser test, including
> the callback tool. A local German phone number (05352, Schöningen) has been
> ordered from Telnyx and is waiting for the regulatory approval required for
> German local numbers. Until then, the agent is not reachable by phone.

---

## Contents

- [How it works](#how-it-works)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Security](#security)
- [Setup](#setup)
- [Testing the webhook](#testing-the-webhook)
- [Design decisions](#design-decisions)
- [Roadmap](#roadmap)

---

## How it works

```mermaid
sequenceDiagram
    participant C as Caller
    participant N as Nina (ElevenLabs Agent)
    participant G as Nginx
    participant W as n8n workflow
    participant D as PostgreSQL

    C->>N: Asks whether lunch is served at a conference
    N->>C: Not in the knowledge base, offers a callback
    C->>N: Name, phone number, request
    N->>C: Repeats the number digit by digit, caller confirms
    N->>G: POST /webhook/rueckruf (header X-Elmblick-Key)
    G->>W: forwards only /webhook/*
    W->>W: checks name, telefon, anliegen
    W->>D: INSERT INTO rueckrufe
    D-->>W: new row with id
    W-->>N: gespeichert true, id 7
    N->>C: Confirms that the callback request is recorded
```

Every stored request carries the ElevenLabs conversation ID (`anruf_id`), so
each row in the database can be traced back to the call transcript.

---

## Features

- Natural phone conversation in German
- Answers based on a curated knowledge base of the hotel (`agent/knowledge_base.md`)
- **Tool calling:** Nina decides on her own when a callback request is needed
  and sends it to the webhook with name, phone number, request, availability
  and conversation ID
- Phone numbers are always repeated digit by digit and confirmed before saving
- Server-side validation: incomplete requests are rejected with `400` and a
  list of the missing fields, so Nina can ask for exactly what is missing
- Callback requests stored in PostgreSQL with status `offen`, `erledigt` or
  `nicht_erreicht`
- Honest by design: Nina says she is an AI, never confirms a booking, never
  promises a callback time and never claims to have saved something when the
  tool failed
- Ends the call politely once the caller has said goodbye, and on silence
- Cost limits: maximum call duration of five minutes and a monthly spending cap

---

## Tech Stack

| Component        | Used for                                                  |
| ---------------- | --------------------------------------------------------- |
| ElevenLabs Agents| Speech recognition, LLM, voice, webhook tool              |
| n8n 2.43         | Webhook, validation and database insert                   |
| PostgreSQL 16    | Callback requests (own database `hotel`)                  |
| Docker Compose   | Runs n8n and PostgreSQL on the server                     |
| Nginx            | Reverse proxy, exposes only the webhook path              |
| Let's Encrypt    | TLS certificate via certbot                               |
| Ubuntu 24.04 VPS | Hostinger, shared with other projects                     |
| Telnyx           | German local phone number via SIP trunk (pending)         |

---

## Project Structure

```
Voice-Agent-Hotel/
├── agent/
│   ├── system_prompt.md            # Nina's instructions (German)
│   ├── knowledge_base.md           # What Nina knows about the hotel (German)
│   └── tool_rueckruf_aufnehmen.json  # Webhook tool as exported from ElevenLabs
├── n8n/
│   └── elmblick_rueckrufbitte.json # Workflow export: Webhook → If → Postgres → Respond
├── server/
│   ├── compose.yaml                # n8n + PostgreSQL
│   ├── nginx-n8n.conf              # Only /webhook/ is public
│   └── .env.example                # Required secrets, without values
└── sql/
    └── 001_hotel_database.sql      # Database, role and table for callback requests
```

---

## Security

- **Only the webhook is public.** Nginx forwards `/webhook/` to n8n and answers
  every other path with `404`, including the editor, the login page and
  `/healthz`. The editor is opened through an SSH tunnel only.
- **Shared secret.** The webhook uses n8n Header Auth (`X-Elmblick-Key`).
  In ElevenLabs the key is stored as a secret, so the language model never
  sees it. Requests without the key get `403`.
- **Ports bound to localhost.** Docker publishes n8n only on
  `127.0.0.1:5678`. This matters because Docker writes its own firewall rules
  in front of `ufw`; a plain `5678:5678` would be reachable from the internet
  even though `ufw` claims otherwise. PostgreSQL has no published port at all.
- **Least privilege.** n8n writes with its own role `hotel_app`, which owns
  only the database `hotel`. Connecting to n8n's internal database is revoked
  for everyone else.
- **Secrets stay on the server.** `.env` with the database password and the
  n8n encryption key is never committed; see `server/.env.example`.
- **Memory limits.** n8n is capped at 1 GB and PostgreSQL at 512 MB, so the
  agent can never starve the other services on the same VPS.

---

## Setup

### 1. Server

Requires Docker with the Compose plugin, Nginx and certbot.

```bash
sudo mkdir -p /opt/voice-agent && sudo chown $USER:$USER /opt/voice-agent
# copy server/compose.yaml to /opt/voice-agent/
cd /opt/voice-agent
( umask 077; { echo "POSTGRES_PASSWORD=$(openssl rand -hex 24)"; \
  echo "N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)"; } > .env )
sudo docker compose up -d
curl -s http://127.0.0.1:5678/healthz   # {"status":"ok"}
```

Adjust the domain in `compose.yaml` and `nginx-n8n.conf`, then:

```bash
sudo install -m 644 -o root -g root nginx-n8n.conf /etc/nginx/sites-available/n8n
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d n8n.example.com
```

### 2. Database

```bash
sudo docker compose exec postgres psql -U n8n -d n8n
```

Then run the statements from `sql/001_hotel_database.sql` step by step. The
password for `hotel_app` is set interactively with `\password`.

### 3. n8n

Open the editor through the tunnel
(`ssh -N -L 15678:127.0.0.1:5678 <server>`, then `http://localhost:15678`),
create the owner account and two credentials:

- **Postgres:** host `postgres`, database `hotel`, user `hotel_app`, SSL disabled
- **Header Auth:** name `X-Elmblick-Key`, value from `openssl rand -hex 32`

Import `n8n/elmblick_rueckrufbitte.json`, assign the credentials and publish
the workflow.

### 4. ElevenLabs

Create an agent, paste `agent/system_prompt.md` as the system prompt and add
`agent/knowledge_base.md` to the knowledge base. Create the webhook tool from
`agent/tool_rueckruf_aufnehmen.json` and store the key as a secret header.
Enable the system tool `end_call`.

---

## Testing the webhook

```bash
read -s KEY   # paste the webhook key, nothing is shown

# complete request: 200
curl -s -X POST https://n8n.example.com/webhook/rueckruf \
  -H "Content-Type: application/json" -H "X-Elmblick-Key: $KEY" \
  -d '{"name":"Test","telefon":"05352 123456","anliegen":"Frage zur Anreise"}'
# {"gespeichert":true,"id":6}

# missing phone number: 400
curl -s -X POST https://n8n.example.com/webhook/rueckruf \
  -H "Content-Type: application/json" -H "X-Elmblick-Key: $KEY" \
  -d '{"name":"   ","anliegen":"Test"}'
# {"gespeichert":false,"fehlt":["name","telefon"]}

# without key: 403
```

---

## Design decisions

- **Nina takes every call, the team calls back.** She is the first point of
  contact, not an overflow line. She never refers callers to the reception or
  another number, and bookings go through the hotel website.
- **Requests, not bookings.** Nina never confirms a room, a late check-out or
  an arrival after 22:00. She only says what actually happened.
- **No payment data on the phone.** If a caller starts reading out card
  details, Nina interrupts politely.
- **The caller hangs up first.** As at any good reception, Nina says goodbye
  once and ends the call only after the caller has said goodbye too.
- **Fictional hotel, real place.** The hotel and all prices are invented, the
  directions and surroundings of Schöningen are real.

---

## Roadmap

1. **Live with information** (done except for the phone number):
   questions, callback requests, database
2. **Availability and booking requests:** check free rooms for a period from a
   price table and record the request
3. **Service during the stay:** wake-up calls, late check-out or a table in
   the restaurant as tasks for the team, based on the room number
4. **Evaluation:** store every call via post-call webhook and analyse it with
   SQL, for example the share of calls solved without a callback
