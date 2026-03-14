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
    return data.get("programme",
                    
from datetime import datetime, timedelta

def date_str(dt):
    return dt.strftime("%d%m%Y")


def iter_last_days(days=365):
    today_dt = datetime.now()
    for i in range(days):
        yield date_str(today_dt - timedelta(days=i))
