-- Babies up to 2 sleep in a cot and take no bed, at most one cot per room.
ALTER TABLE buchungsanfragen
    ADD COLUMN babys smallint NOT NULL DEFAULT 0 CHECK (babys BETWEEN 0 AND 1);
