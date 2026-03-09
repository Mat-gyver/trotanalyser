import requests
import sqlite3
import sys
from datetime import datetime, timedelta
from bs4 import BeautifulSoup

DB="trotanalyser.db"

HEADERS={"User-Agent":"Mozilla/5.0"}

def daterange(start,end):
    start=datetime.strptime(start,"%d/%m/%Y")
    end=datetime.strptime(end,"%d/%m/%Y")
    d=start
    while d<=end:
        yield d.strftime("%Y-%m-%d"),d.strftime("%d/%m/%Y")
        d+=timedelta(days=1)

def ensure_table(conn):
    cur=conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS historical_races_letrot(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_course TEXT,
        hippo TEXT,
        reunion TEXT,
        course TEXT
    )
    """)
    conn.commit()

def parse_meeting(day_iso,meeting_id):

    url=f"https://www.letrot.com/courses/programme/{day_iso}/{meeting_id}"

    r=requests.get(url,headers=HEADERS,timeout=20)

    if r.status_code!=200:
        return []

    soup=BeautifulSoup(r.text,"html.parser")

    text=soup.get_text()

    if "C1" not in text:
        return []

    rows=[]

    courses=set()

    for i in range(1,20):
        c=f"C{i}"
        if c in text:
            courses.add(c)

    reunion=f"R{meeting_id}"

    for c in courses:
        rows.append((reunion,c))

    return rows

def save(conn,day_fr,rows):

    cur=conn.cursor()

    inserted=0

    for reunion,course in rows:

        cur.execute("""
        INSERT INTO historical_races_letrot(date_course,reunion,course)
        VALUES(?,?,?)
        """,(day_fr,reunion,course))

        inserted+=1

    conn.commit()

    return inserted


def main(start,end):

    conn=sqlite3.connect(DB)

    ensure_table(conn)

    total=0

    for day_iso,day_fr in daterange(start,end):

        day_total=0

        for meeting_id in range(1,40):

            rows=parse_meeting(day_iso,meeting_id)

            if rows:

                inserted=save(conn,day_fr,rows)

                day_total+=inserted

        total+=day_total

        print(day_fr,"->",day_total,"courses")

    print("TOTAL LETROT =",total)

    conn.close()


if __name__=="__main__":

    if len(sys.argv)!=3:
        print("usage: python3 import_letrot_history.py JJ/MM/AAAA JJ/MM/AAAA")
        sys.exit()

    main(sys.argv[1],sys.argv[2])
