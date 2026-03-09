CREATE TABLE IF NOT EXISTS historical_races (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_course TEXT,
    hippo TEXT,
    reunion TEXT,
    course TEXT,
    prix TEXT,
    discipline TEXT,
    distance INTEGER,
    montant TEXT,
    nb_partants INTEGER,
    non_partants TEXT,
    arrivee TEXT,
    details TEXT,
    source TEXT DEFAULT 'open-pmu-api'
);

CREATE INDEX IF NOT EXISTS idx_historical_races_date ON historical_races(date_course);
CREATE INDEX IF NOT EXISTS idx_historical_races_hippo ON historical_races(hippo);
