-- Stage 4: what each call led to (run once, after 007).
-- The outcome is not stored anywhere. It follows from the request tables,
-- linked by the ElevenLabs conversation ID.
-- Connect as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d hotel

SET ROLE hotel_owner;

CREATE VIEW anruf_ergebnisse AS
SELECT a.*,
       CASE
           WHEN EXISTS (SELECT 1 FROM buchungsanfragen b WHERE b.anruf_id = a.anruf_id)
               THEN 'buchungsanfrage'
           WHEN EXISTS (SELECT 1 FROM rueckrufe r WHERE r.anruf_id = a.anruf_id)
               THEN 'rueckruf'
           ELSE 'auskunft'
       END AS ergebnis
FROM anrufe a;

RESET ROLE;
