#!/bin/sh
# Runs once, when the local database is created for the first time.
# Every migration from sql/ in order, like on the server and in the CI.
# \password needs a keyboard, so every role gets the local password "lokal".
set -e

for f in /sql/0*.sql; do
    echo "== $f"
    case "$f" in
        /sql/001_*|/sql/002_*) db=n8n ;;
        *) db=hotel ;;
    esac
    sed "s/^\\\\password \\([a-z_]*\\)$/ALTER ROLE \\1 PASSWORD 'lokal';/" "$f" \
        | psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$db" -f -
done
