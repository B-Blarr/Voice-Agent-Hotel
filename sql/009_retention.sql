-- Retention: personal data does not stay forever (run once, after 008).
-- Booking requests and callback requests hold names and phone numbers and go after 30 days.
-- Calls hold no names or numbers by design, but the title comes from the LLM, so they go after 90 days.
-- A daily n8n workflow calls alte_daten_loeschen() as hotel_app.
-- Connect as the superuser from compose.yaml:
--   sudo docker compose exec postgres psql -U n8n -d hotel

SET ROLE hotel_owner;

-- SECURITY DEFINER: the function runs with the rights of its owner hotel_owner.
-- hotel_app may call it, but still cannot delete a single row on its own.
CREATE FUNCTION alte_daten_loeschen()
RETURNS TABLE (tabelle text, geloescht bigint)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    anzahl bigint;
BEGIN
    DELETE FROM buchungsanfragen WHERE erstellt_am < now() - interval '30 days';
    GET DIAGNOSTICS anzahl = ROW_COUNT;
    tabelle := 'buchungsanfragen'; geloescht := anzahl; RETURN NEXT;

    DELETE FROM rueckrufe WHERE erstellt_am < now() - interval '30 days';
    GET DIAGNOSTICS anzahl = ROW_COUNT;
    tabelle := 'rueckrufe'; geloescht := anzahl; RETURN NEXT;

    DELETE FROM anrufe WHERE beginn < now() - interval '90 days';
    GET DIAGNOSTICS anzahl = ROW_COUNT;
    tabelle := 'anrufe'; geloescht := anzahl; RETURN NEXT;
END;
$$;

RESET ROLE;

-- Only the workflow role may call it.
REVOKE EXECUTE ON FUNCTION alte_daten_loeschen() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION alte_daten_loeschen() TO hotel_app;
