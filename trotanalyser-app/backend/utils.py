def safe_float(value, default=0.0):
    try:
        if value is None or value == "":
            return default
        return float(str(value).replace(" ", "").replace(",", "."))
    except Exception:
        return default


def safe_int(value, default=0):
    try:
        if value is None or value == "":
            return default
        return int(float(value))
    except Exception:
        return default


def upper_text(value):
    return str(value or "").upper().strip()
