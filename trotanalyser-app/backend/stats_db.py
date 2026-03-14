import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "trot_stats.db"


def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS race_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            race_date TEXT NOT NULL,
            reunion TEXT,
            course TEXT,
            hippodrome TEXT,
            distance INTEGER,
            cheval TEXT,
            numero INTEGER,
            driver TEXT,
            entraineur TEXT,
            position INTEGER,
            allocation REAL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
        """
    )

    cur.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_race_results_date
        ON race_results (race_date)
        """
    )

    cur.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_race_results_driver
        ON race_results (driver)
        """
    )

    cur.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_race_results_entraineur
        ON race_results (entraineur)
        """
    )

    conn.commit()
    conn.close()


def insert_race_result(
    race_date,
    reunion,
    course,
    hippodrome,
    distance,
    cheval,
    numero,
    driver,
    entraineur,
    position,
    allocation=None,
):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        INSERT INTO race_results (
            race_date, reunion, course, hippodrome, distance,
            cheval, numero, driver, entraineur, position, allocation
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            race_date,
            reunion,
            course,
            hippodrome,
            distance,
            cheval,
            numero,
            driver,
            entraineur,
            position,
            allocation,
        ),
    )

    conn.commit()
    conn.close()


def get_results_since(start_date):
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT *
        FROM race_results
        WHERE race_date >= ?
        ORDER BY race_date DESC
        """,
        (start_date,),
    )

    rows = [dict(row) for row in cur.fetchall()]
    conn.close()
    return rows
