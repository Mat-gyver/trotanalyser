def analyse_forme(musique):

    if not musique:
        return "forme récente peu lisible"

    if "1" in musique[:4]:
        return "forme récente favorable"

    return "forme récente correcte"
