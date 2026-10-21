-- Availability check for Nina and, later, the website.
-- One call returns every room category that fits the guests, with the number
-- of free rooms in the period and the price. Categories that do not fit at all
-- are left out; categories that fit but are booked out come back with 0.
--
--   sudo docker compose exec postgres psql -U n8n -d hotel

SET ROLE hotel_owner;

CREATE FUNCTION verfuegbarkeit(
    p_anreise         date,
    p_abreise         date,
    p_erwachsene      int,
    p_kinder          int     DEFAULT 0,
    p_babys           int     DEFAULT 0,
    p_betten_getrennt boolean DEFAULT false,
    p_barrierefrei    boolean DEFAULT false
)
RETURNS TABLE (
    kategorie       text,
    name            text,
    freie_zimmer    bigint,
    naechte         int,
    preis_pro_nacht numeric,
    gesamtpreis     numeric
)
LANGUAGE sql STABLE
AS $$
    SELECT k.code,
           k.name,
           count(*) FILTER (WHERE NOT EXISTS (
               SELECT 1
               FROM belegungen b
               WHERE b.zimmer = z.nummer
                 AND b.anreise < p_abreise
                 AND b.abreise > p_anreise
           )),
           p_abreise - p_anreise,
           CASE
               WHEN p_erwachsene = 1 AND p_kinder = 0 AND k.preis_alleinnutzung IS NOT NULL
               THEN k.preis_alleinnutzung
               ELSE k.preis_pro_nacht
           END,
           (p_abreise - p_anreise) * CASE
               WHEN p_erwachsene = 1 AND p_kinder = 0 AND k.preis_alleinnutzung IS NOT NULL
               THEN k.preis_alleinnutzung
               ELSE k.preis_pro_nacht
           END
    FROM zimmer z
    JOIN zimmerkategorien k ON k.code = z.kategorie
    WHERE p_erwachsene <= k.betten
      AND p_erwachsene + p_kinder <= k.betten + k.zustellbett::int
      AND p_babys <= 1
      AND (NOT p_betten_getrennt OR z.betten_trennbar)
      AND (NOT p_barrierefrei OR z.barrierefrei)
    GROUP BY k.code, k.name, k.preis_pro_nacht, k.preis_alleinnutzung
    ORDER BY k.preis_pro_nacht
$$;

RESET ROLE;

-- Functions may be called by everyone by default. Only hotel_app needs it.
REVOKE EXECUTE ON FUNCTION verfuegbarkeit FROM PUBLIC;
GRANT EXECUTE ON FUNCTION verfuegbarkeit TO hotel_app;
