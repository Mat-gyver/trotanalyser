#!/bin/bash
set -e

HOOK_FILE="hooks/useCourseAnalysis.ts"
CARD_FILE="components/course/CourseHorseInlineCard.tsx"
BACKUP_DIR="backups/integrate_signals_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$BACKUP_DIR"

cp "$HOOK_FILE" "$BACKUP_DIR/$(basename "$HOOK_FILE")"
cp "$CARD_FILE" "$BACKUP_DIR/$(basename "$CARD_FILE")"

echo "Backups créés dans : $BACKUP_DIR"

python3 <<'PY'
from pathlib import Path
import re

hook = Path("hooks/useCourseAnalysis.ts")
card = Path("components/course/CourseHorseInlineCard.tsx")

hook_s = hook.read_text(encoding="utf-8", errors="ignore")
card_s = card.read_text(encoding="utf-8", errors="ignore")

# ============================================================
# 1) HOOK: helpers value/favori/tocard/pace
# ============================================================

helpers_block = r'''
const impliedProb = (cote?: number | null) => {
  const c = Number(cote || 0);
  if (!c || c <= 0) return 0;
  return 100 / c;
};

const computeValueSignal = (p: any) => {
  const probIA = Number(p?.probabiliteIA || 0);
  const probPMU = impliedProb(p?.cotePMU);
  return Math.round((probIA - probPMU) * 10) / 10;
};

const isFavoriFragile = (p: any) => {
  const cotePMU = Number(p?.cotePMU || 0);
  const scoreIA = Number(p?.scoreIA || 0);
  const driverIndex = Number(p?.driverIndex || 0);

  return cotePMU > 0 && cotePMU <= 3 && scoreIA < 15 && driverIndex < 5;
};

const isGrosTocard = (p: any) => {
  const probIA = Number(p?.probabiliteIA || 0);
  const cotePMU = Number(p?.cotePMU || 0);
  const retardGains = Number(p?.retardGains || 0);

  return probIA >= 10 && cotePMU >= 20 && retardGains >= 5;
};

const detectRunStyle = (p: any) => {
  const txt = String(
    p?.analyseIA || p?.dataTurfPro || p?.shortAnalyse || ""
  ).toLowerCase();

  if (
    txt.includes("vite") ||
    txt.includes("en tête") ||
    txt.includes("anime") ||
    txt.includes("allant") ||
    txt.includes("devant")
  ) return "leader";

  if (
    txt.includes("attentiste") ||
    txt.includes("attendre") ||
    txt.includes("caché") ||
    txt.includes("sur une 3e ligne")
  ) return "closer";

  if (
    txt.includes("progression") ||
    txt.includes("vient bien") ||
    txt.includes("finisseur") ||
    txt.includes("finit vite")
  ) return "finisher";

  return "neutral";
};

const buildPaceAnalysis = (participants: any[]) => {
  const list = Array.isArray(participants) ? participants : [];

  const leaders = list.filter((p) => detectRunStyle(p) === "leader");
  const closers = list.filter((p) => detectRunStyle(p) === "closer");
  const finishers = list.filter((p) => detectRunStyle(p) === "finisher");

  let train: "LENT" | "NORMAL" | "RAPIDE" = "NORMAL";
  if (leaders.length >= 3) train = "RAPIDE";
  else if (leaders.length <= 1) train = "LENT";

  const alerts: string[] = [];
  if (train === "RAPIDE" && finishers.length > 0) {
    alerts.push("Rythme rapide : avantage aux finisseurs");
  }
  if (train === "LENT" && leaders.length > 0) {
    alerts.push("Rythme lent : avantage aux chevaux près de la tête");
  }
  if (leaders.length >= 4) {
    alerts.push("Possible bagarre en tête");
  }

  return {
    train,
    leaders,
    closers,
    finishers,
    alerts,
  };
};

const enrichParticipantSignals = (p: any, pace: any) => {
  const valueSignal = computeValueSignal(p);
  const favoriFragile = isFavoriFragile(p);
  const grosTocard = isGrosTocard(p);

  const baseBadges = Array.isArray(p?.badges) ? [...p.badges] : [];

  if (valueSignal > 8 && !baseBadges.includes("VALUE BET")) {
    baseBadges.push("VALUE BET");
  }
  if (valueSignal > 15 && !baseBadges.includes("VALUE FORTE")) {
    baseBadges.push("VALUE FORTE");
  }
  if (favoriFragile && !baseBadges.includes("FAVORI FRAGILE")) {
    baseBadges.push("FAVORI FRAGILE");
  }
  if (grosTocard && !baseBadges.includes("GROS TOCARD")) {
    baseBadges.push("GROS TOCARD");
  }

  const style = detectRunStyle(p);
  if (pace?.train === "RAPIDE" && (style === "finisher" || style === "closer")) {
    if (!baseBadges.includes("PROFIL RYTHME")) {
      baseBadges.push("PROFIL RYTHME");
    }
  }
  if (pace?.train === "LENT" && style === "leader") {
    if (!baseBadges.includes("PROFIL RYTHME")) {
      baseBadges.push("PROFIL RYTHME");
    }
  }

  return {
    ...p,
    valueSignal,
    favoriFragile,
    grosTocard,
    runStyle: style,
    badges: baseBadges,
  };
};
'''

if "const impliedProb = (cote?" not in hook_s:
    # place helpers before export/useCourseAnalysis if possible
    m = re.search(r'(export\s+function\s+useCourseAnalysis|export\s+const\s+useCourseAnalysis|export\s+default\s+function\s+useCourseAnalysis)', hook_s)
    if m:
        hook_s = hook_s[:m.start()] + helpers_block + "\n" + hook_s[m.start():]
    else:
        hook_s = helpers_block + "\n" + hook_s

# ============================================================
# 2) HOOK: inject pace + enrich participants
# ============================================================

# Try to find sortedParticipants assignment and replace result usage safely
if "const paceAnalysis = buildPaceAnalysis" not in hook_s:
    # insert after participants/data normalization area or near start of hook body
    hook_s = re.sub(
        r'(\{\s*sortedParticipants[\s\S]*?=\s*useMemo\()',
        r'\1',
        hook_s,
        count=1
    )

# Common replacement patterns
patterns = [
    # const sortedParticipants = useMemo(...)
    (
        r'(const\s+sortedParticipants\s*=\s*useMemo\(\s*\(\)\s*=>\s*)(\[[\s\S]*?\]\s*\.sort\([\s\S]*?\)|[\s\S]*?return\s+[\s\S]*?;\s*)\s*,\s*\[data\]\s*\)',
        None
    ),
]

# Safer: if sortedParticipants const exists, append paceAnalysis after it if not already
m_sorted = re.search(r'const\s+sortedParticipants\s*=\s*useMemo\([\s\S]*?\n\s*\);', hook_s)
if m_sorted and "const paceAnalysis = useMemo" not in hook_s:
    insert_at = m_sorted.end()
    block = r'''

  const paceAnalysis = useMemo(() => {
    return buildPaceAnalysis(sortedParticipants as any[]);
  }, [sortedParticipants]);

'''
    hook_s = hook_s[:insert_at] + block + hook_s[insert_at:]

# Enrich top3/value bets by converting sortedParticipants source if not already using valueSignal
# Replace valueBets computation if found
hook_s = re.sub(
    r'const\s+valueBets\s*=\s*useMemo\([\s\S]*?\n\s*\);',
    r'''const valueBets = useMemo(() => {
    return (sortedParticipants as any[])
      .map((p) => enrichParticipantSignals(p, paceAnalysis))
      .filter((p) => Number(p.valueSignal || 0) > 8)
      .sort((a, b) => Number(b.valueSignal || 0) - Number(a.valueSignal || 0));
  }, [sortedParticipants, paceAnalysis]);''',
    hook_s,
    count=1
)

# Add enriched participants export/return usage
# If return block exists, add paceAnalysis and enriched list fields
ret_match = re.search(r'return\s*\{([\s\S]*?)\n\s*\};', hook_s)
if ret_match:
    body = ret_match.group(1)
    additions = []
    if "paceAnalysis" not in body:
        additions.append("paceAnalysis,")
    if "top3IA" not in body and "top3IA" in hook_s:
        pass
    if "valueBets" not in body:
        additions.append("valueBets,")
    if "topValue" not in body:
        additions.append("topValue: valueBets[0] || null,")
    if additions:
        new_body = body.rstrip() + "\n    " + "\n    ".join(additions) + "\n  "
        hook_s = hook_s[:ret_match.start(1)] + new_body + hook_s[ret_match.end(1):]

# If top3IA computation exists, enrich its participants
hook_s = re.sub(
    r'const\s+top3IA\s*=\s*useMemo\(\(\)\s*=>\s*\(?\s*(sortedParticipants(?:\s+as\s+any\[\])?)\.slice\(0,\s*3\)\s*\)?\s*,\s*\[sortedParticipants\]\s*\);',
    r'''const top3IA = useMemo(() => {
    return (sortedParticipants as any[])
      .map((p) => enrichParticipantSignals(p, paceAnalysis))
      .slice(0, 3);
  }, [sortedParticipants, paceAnalysis]);''',
    hook_s,
    count=1
)

# If sortedParticipants is returned raw, expose enrichedSortedParticipants variable
if "const enrichedSortedParticipants = useMemo" not in hook_s and "sortedParticipants" in hook_s:
    m_pa = re.search(r'const\s+paceAnalysis\s*=\s*useMemo\([\s\S]*?\n\s*\);', hook_s)
    if m_pa:
        insert_at = m_pa.end()
        block = r'''

  const enrichedSortedParticipants = useMemo(() => {
    return (sortedParticipants as any[]).map((p) => enrichParticipantSignals(p, paceAnalysis));
  }, [sortedParticipants, paceAnalysis]);
'''
        hook_s = hook_s[:insert_at] + block + hook_s[insert_at:]
        hook_s = re.sub(r'\bsortedParticipants\b(?=\s*,|\s*\n)', 'enrichedSortedParticipants', hook_s, count=1)

# More targeted return block update for sortedParticipants
hook_s = re.sub(
    r'return\s*\{\s*([^}]*?)sortedParticipants\s*,',
    r'return {\n    \1sortedParticipants: enrichedSortedParticipants,',
    hook_s,
    count=1
)

hook.write_text(hook_s, encoding="utf-8")

# ============================================================
# 3) CARD: add badge rendering for new signals + pace
# ============================================================

# Ensure prop access variable
if "participant" in card_s and "const c =" not in card_s:
    # derive c from participant if component uses participant prop
    card_s = re.sub(
        r'(export\s+default\s+function\s+\w+\s*\(\s*\{[^}]*participant[^}]*\}\s*:\s*Props\s*\)\s*\{)',
        r'\1\n  const c = participant as any;',
        card_s,
        count=1
    )

# If component uses c prop already, leave it

badge_insert = r'''
      {!!(c as any)?.favoriFragile && (
        <View style={[styles.badge, styles.badgeFragile]}>
          <Text style={styles.badgeText}>⚠️ FAVORI FRAGILE</Text>
        </View>
      )}

      {Number((c as any)?.valueSignal || 0) > 8 && (
        <View style={[styles.badge, Number((c as any)?.valueSignal || 0) > 15 ? styles.badgeValueStrong : styles.badgeValue]}>
          <Text style={styles.badgeText}>
            {Number((c as any)?.valueSignal || 0) > 15 ? "🔥 VALUE FORTE" : "🔥 VALUE BET"}
          </Text>
        </View>
      )}

      {!!(c as any)?.grosTocard && (
        <View style={[styles.badge, styles.badgeTocard]}>
          <Text style={styles.badgeText}>💣 GROS TOCARD</Text>
        </View>
      )}

      {!!(c as any)?.runStyle && (
        <View style={[styles.badge, styles.badgePace]}>
          <Text style={styles.badgeText}>
            {`🏇 ${String((c as any).runStyle).toUpperCase()}`}
          </Text>
        </View>
      )}
'''

# Insert after badges row title or before card body
if "💣 GROS TOCARD" not in card_s:
    m = re.search(r'(<View\s+style=\{styles\.badgesRow\}>[\s\S]*?</View>)', card_s)
    if m:
        card_s = card_s[:m.end()] + "\n" + badge_insert + card_s[m.end()]
    else:
        # fallback before cardBody or return end
        m2 = re.search(r'(<View\s+style=\{styles\.cardBody\}>)', card_s)
        if m2:
            card_s = card_s[:m2.start()] + badge_insert + "\n" + card_s[m2.start():]

# Add pace mini-summary if not present
pace_summary = r'''
      {!!(c as any)?.valueSignal && (
        <Text style={styles.microStats}>
          Value : {Number((c as any).valueSignal || 0) > 0 ? "+" : ""}{Number((c as any).valueSignal || 0)} pts
        </Text>
      )}
'''
if "Value :" not in card_s:
    m = re.search(r'(</View>\s*</View>\s*</View>\s*</View>)', card_s)
    # too risky, instead insert before final closing of card body if possible
    m2 = re.search(r'(<Text\s+style=\{styles\.microStats\}>[\s\S]*?</Text>)', card_s)
    if m2:
        card_s = card_s[:m2.end()] + "\n" + pace_summary + card_s[m2.end()]

card.write_text(card_s, encoding="utf-8")
PY

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true

echo
echo "=== VERIFICATION HOOK ==="
grep -n "impliedProb\\|computeValueSignal\\|isFavoriFragile\\|isGrosTocard\\|buildPaceAnalysis\\|paceAnalysis" "$HOOK_FILE" || true

echo
echo "=== VERIFICATION CARD ==="
grep -n "FAVORI FRAGILE\\|VALUE BET\\|VALUE FORTE\\|GROS TOCARD\\|runStyle\\|Value :" "$CARD_FILE" || true
