import sqlite3
import requests
import time

conn = sqlite3.connect("trotanalyser.db")
cur = conn.cursor()

cur.execute("""
SELECT id,date_course,reunion,course
FROM races
LIMIT 114793
""")

races = cur.fetchall()

for race in races:

    race_id = race[0]
    date = race[1]
    reunion = race[2]
    course = race[3]

    try:

        date_api = date.replace("-","")

        url = f"https://online.turfinfo.api.pmu.fr/rest/client/62/programme/{date_api}/{reunion}/{course}/participants"

        r = requests.get(url, headers={"User-Agent":"Mozilla/5.0"})
        data = r.json()

        participants = data["participants"]

        for p in participants:

            horse = p["nom"]
            driver = p["driver"]
            trainer = p["entraineur"]
            num = p["numPmu"]
            age = p["age"]
            musique = p["musique"]

            cur.execute("SELECT id FROM horses WHERE name=?", (horse,))
            row = cur.fetchone()

            if row:
                horse_id = row[0]
            else:
                cur.execute("INSERT INTO horses(name) VALUES(?)",(horse,))
                horse_id = cur.lastrowid

            cur.execute("SELECT id FROM drivers WHERE name=?", (driver,))
            row = cur.fetchone()

            if row:
                driver_id = row[0]
            else:
                cur.execute("INSERT INTO drivers(name) VALUES(?)",(driver,))
                driver_id = cur.lastrowid

            cur.execute("SELECT id FROM trainers WHERE name=?", (trainer,))
            row = cur.fetchone()

            if row:
                trainer_id = row[0]
            else:
                cur.execute("INSERT INTO trainers(name) VALUES(?)",(trainer,))
                trainer_id = cur.lastrowid

            cur.execute("""
            INSERT INTO runners(
                race_id,
                horse_id,
                driver_id,
                trainer_id,
                num_pmu,
                age,
                musique
            )
            VALUES(?,?,?,?,?,?,?)
            """,(race_id,horse_id,driver_id,trainer_id,num,age,musique))

        conn.commit()

        print("OK race",race_id)

        time.sleep(0.2)

    except Exception as e:

        print("Erreur",race_id,e)

conn.close()

print("IMPORT TERMINE")
