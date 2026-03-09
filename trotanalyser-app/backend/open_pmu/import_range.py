import subprocess
from datetime import datetime, timedelta
import sys

if len(sys.argv) != 3:
    print("Usage: python3 open_pmu/import_range.py JJ/MM/AAAA JJ/MM/AAAA")
    raise SystemExit(1)

start = datetime.strptime(sys.argv[1], "%d/%m/%Y")
end = datetime.strptime(sys.argv[2], "%d/%m/%Y")

current = start
while current <= end:
    d = current.strftime("%d/%m/%Y")
    print(f"=== Import {d} ===")
    subprocess.run(["python3", "open_pmu/import_open_pmu_history.py", d], check=False)
    current += timedelta(days=1)
