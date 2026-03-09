import sqlite3

DB = "trotanalyser.db"

schema = """
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS odds_history;
DROP TABLE IF EXISTS horse_history_features;
DROP TABLE IF EXISTS runners;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS horses;
DROP TABLE IF EXISTS races;

CREATE TABLE races (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source TEXT,
    date_course TEXT NOT NULL,
    annee INTEGER,
    hippo TEXT,
    pays TEXT,
    reunion TEXT,
    course TEXT,
    libelle TEXT,
    discipline TEXT,
    specialite TEXT,
    distance INTEGER,
    type_depart TEXT,
    corde TEXT,
    allocation REAL,
    nb_partants INTEGER,
    piste TEXT,
    meteo TEXT,
    temperature REAL,
    vent_kmh REAL,
    statut TEXT
);

CREATE TABLE horses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL UNIQUE,
    sexe TEXT,
    annee_naissance INTEGER,
    origine TEXT
);

CREATE TABLE drivers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL UNIQUE
);

CREATE TABLE trainers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL UNIQUE
);

CREATE TABLE runners (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    race_id INTEGER NOT NULL,
    horse_id INTEGER,
    driver_id INTEGER,
    trainer_id INTEGER,
    num_pmu INTEGER,
    corde INTEGER,
    age INTEGER,
    gains_carriere REAL,
    gains_annee REAL,
    musique TEXT,
    ferrure TEXT,
    handicap_distance INTEGER,
    reduction_km TEXT,
    chrono TEXT,
    cote_pmu REAL,
    cote_ref REAL,
    favori INTEGER DEFAULT 0,
    place_arrivee INTEGER,
    disqualifie INTEGER DEFAULT 0,
    non_partant INTEGER DEFAULT 0,
    distance_fautive INTEGER,
    commentaire TEXT,
    FOREIGN KEY (race_id) REFERENCES races(id) ON DELETE CASCADE,
    FOREIGN KEY (horse_id) REFERENCES horses(id) ON DELETE SET NULL,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainers(id) ON DELETE SET NULL
);

CREATE TABLE horse_history_features (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    runner_id INTEGER NOT NULL,
    nb_courses_30j INTEGER,
    nb_courses_90j INTEGER,
    taux_victoire_30j REAL,
    taux_place_30j REAL,
    taux_victoire_driver_90j REAL,
    taux_place_driver_90j REAL,
    taux_victoire_entraineur_90j REAL,
    taux_place_entraineur_90j REAL,
    perf_distance REAL,
    perf_hippo REAL,
    perf_corde REAL,
    perf_depart_autostart REAL,
    perf_depart_volte REAL,
    perf_ferrure REAL,
    forme_score REAL,
    regularite_score REAL,
    FOREIGN KEY (runner_id) REFERENCES runners(id) ON DELETE CASCADE
);

CREATE TABLE odds_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    race_id INTEGER NOT NULL,
    horse_id INTEGER,
    horodatage TEXT NOT NULL,
    cote_pmu REAL,
    rapport_probable REAL,
    FOREIGN KEY (race_id) REFERENCES races(id) ON DELETE CASCADE,
    FOREIGN KEY (horse_id) REFERENCES horses(id) ON DELETE SET NULL
);

CREATE INDEX idx_races_date ON races(date_course);
CREATE INDEX idx_races_annee ON races(annee);
CREATE INDEX idx_races_hippo ON races(hippo);
CREATE INDEX idx_races_reunion_course ON races(reunion, course);

CREATE INDEX idx_horses_nom ON horses(nom);
CREATE INDEX idx_drivers_nom ON drivers(nom);
CREATE INDEX idx_trainers_nom ON trainers(nom);

CREATE INDEX idx_runners_race_id ON runners(race_id);
CREATE INDEX idx_runners_horse_id ON runners(horse_id);
CREATE INDEX idx_runners_driver_id ON runners(driver_id);
CREATE INDEX idx_runners_trainer_id ON runners(trainer_id);
CREATE INDEX idx_runners_place ON runners(place_arrivee);
CREATE INDEX idx_runners_num_pmu ON runners(num_pmu);

CREATE INDEX idx_features_runner_id ON horse_history_features(runner_id);

CREATE INDEX idx_odds_race_horse_time ON odds_history(race_id, horse_id, horodatage);
"""

conn = sqlite3.connect(DB)
cur = conn.cursor()
cur.executescript(schema)
conn.commit()
conn.close()

print("Schema TrotAnalyser créé avec succès dans", DB)
