# Evaluation criteria

ElevenLabs rates every call after it ends against these criteria (agent →
Analysis → evaluation criteria). Settings for all three: binary rating, scope
"conversation", the agent's default analysis model. The overall result arrives
in the post-call webhook as `call_successful` and is stored in
`anrufe.erfolgreich`. The weekly report lists every call that was not rated
`success`.

The criteria are written in German like the calls and phrased positively,
because the evaluator misread negated criteria in the agent tests.

## anliegen_geklaert

Das Anliegen des Anrufers wurde beantwortet oder als Buchungsanfrage oder Rückrufbitte an das Team weitergegeben. success: Der Anrufer hat eine Antwort bekommen oder sein Anliegen wurde aufgenommen. failure: Der Anrufer hat eine Frage gestellt, die Nina nicht beantworten konnte, und sie hat keinen Rückruf angeboten, oder das Gespräch endete ohne Ergebnis. unknown: Das Gespräch war zu kurz oder enthielt kein Anliegen.

## angaben_aus_quellen

Freie Zimmer und Gesamtpreise für konkrete Daten nennt Nina nur, nachdem das Werkzeug verfuegbarkeit_pruefen im Gespräch ein Ergebnis geliefert hat, und sie gibt dieses Ergebnis richtig wieder. success: Jede solche Angabe stützt sich auf ein Werkzeugergebnis. failure: Nina nennt freie Zimmer oder einen Preis für bestimmte Daten ohne Werkzeugergebnis oder anders als im Ergebnis. unknown: Im Gespräch ging es nicht um freie Zimmer oder Preise für bestimmte Daten.

## daten_bestaetigt

Bevor Nina eine Buchungsanfrage oder Rückrufbitte speichert, wiederholt sie die Telefonnummer Ziffer für Ziffer und der Anrufer bestätigt sie. Bei einer Buchungsanfrage fasst sie außerdem Zimmerart, Anreise, Abreise und Personen zusammen und lässt sie bestätigen. success: Beides ist passiert. failure: Etwas wurde gespeichert, ohne dass Nummer oder Zusammenfassung bestätigt wurden. unknown: Es wurde nichts gespeichert.
