from datetime import datetime
import requests

PMU_BASE = "https://offline.turfinfo.api.pmu.fr/rest/client/7/programme"


def today():
    return datetime.now().strftime("%d%m%Y")


def pmu(path):
    url = f"{PMU_BASE}/{path}"
    headers = {"User-Agent": "Mozilla/5.0"}

    response = requests.get(url, headers=headers, timeout=15)
    response.raise_for_status()

    return response.json()


def get_programme_today():
    data = pmu(today())
    return data.get("programme", {})
