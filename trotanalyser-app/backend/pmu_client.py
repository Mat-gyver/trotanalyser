from datetime import datetime, timedelta

import requests

PMU_BASE = "https://offline.turfinfo.api.pmu.fr/rest/client/7/programme"


def today():
    return datetime.now().strftime("%d%m%Y")


def date_str(dt):
    return dt.strftime("%d%m%Y")


def iter_last_days(days=365):
    today_dt = datetime.now()
    for i in range(days):
        yield date_str(today_dt - timedelta(days=i))


def pmu(path):
    url = f"{PMU_BASE}/{path}"
    headers = {"User-Agent": "Mozilla/5.0"}

    response = requests.get(url, headers=headers, timeout=15)
    response.raise_for_status()

    try:
        return response.json()
    except Exception as exc:
        raise ValueError(f"Réponse PMU non JSON pour {url}") from exc


def get_programme_today():
    data = pmu(today())
    return data.get("programme", {})


def get_programme_by_date(day_str):
    data = pmu(day_str)
    return data.get("programme", {})


def get_participants(day_str, reunion, course):
    r = str(reunion).replace("R", "")
    c = str(course).replace("C", "")
    return pmu(f"{day_str}/R{r}/C{c}/participants")


def get_arrivee_definitive(day_str, reunion, course):
    r = str(reunion).replace("R", "")
    c = str(course).replace("C", "")
    return pmu(f"{day_str}/R{r}/C{c}/arrivee-definitive")
