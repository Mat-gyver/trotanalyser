#!/bin/bash
set -e

FILE="hooks/useCourseAnalysis.ts"
BACKUP="backups/useCourseAnalysis_before_pace_engine_$(date +%Y%m%d_%H%M%S).ts"

mkdir -p backups
cp "$FILE" "$BACKUP"

echo "Backup créé : $BACKUP"

cat > "$FILE" <<'TS'
import { useMemo } from "react"

export function useCourseAnalysis(data: any) {

  const participants = data?.participants || []

  /*
  ===============================
  ANALYSE DU RYTHME DE COURSE
  ===============================
  */

  const paceAnalysis = useMemo(() => {

    const leaders = participants.filter((p:any)=>
      p?.runningStyle === "leader" ||
      p?.runningStyle === "front"
    )

    const closers = participants.filter((p:any)=>
      p?.runningStyle === "closer"
    )

    let pace = "modéré"

    if(leaders.length >= 3) pace = "rapide"
    if(leaders.length <= 1) pace = "lent"

    return {
      pace,
      leaders,
      closers
    }

  },[participants])


  /*
  ===============================
  VALUE BET
  ===============================
  */

  const valueBets = useMemo(()=>{

    return participants
      .map((p:any)=>{

        const ia = p?.aiProbability || 0
        const pmu = p?.pmuProbability || 0

        const value = ia - pmu

        return {
          ...p,
          valueSignal:value
        }

      })
      .sort((a:any,b:any)=>b.valueSignal-a.valueSignal)

  },[participants])


  /*
  ===============================
  TOP 3 IA
  ===============================
  */

  const top3IA = useMemo(()=>{

    return [...participants]
      .sort((a:any,b:any)=>
        (b.aiProbability||0)-(a.aiProbability||0)
      )
      .slice(0,3)

  },[participants])


  return {
    paceAnalysis,
    valueBets,
    top3IA
  }

}
TS

echo
echo "=== TYPESCRIPT ==="
npx tsc --noEmit --pretty false || true
