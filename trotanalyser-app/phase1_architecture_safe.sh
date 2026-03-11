#!/bin/bash
set -e

mkdir -p types services hooks components/course backups

echo "=== Création types/course.ts ==="
cat > types/course.ts <<'TS'
export type Participant = {
  numero: number | string;
  nom: string;
  driver?: string;
  entraineur?: string;
  ferrure?: string;
  musique?: string;
  analyseIA?: string;
  scoreIA?: number;
  probabiliteIA?: number;
  confianceIA?: number;
  cotePMU?: number;
  coteIA?: number;
  value?: number;
  driverIndex?: number;
  trainerIndex?: number;
  retardGains?: number;
  rankIA?: number;
  badges?: string[];
  casaque?: string;
  probabilitePMU?: number;
  gains?: number;
  texteEcartLimite?: string;
  couleurEcartLimite?: string;
};

export type CourseData = {
  reunion: string;
  course: string;
  hippodrome?: string;
  distance?: string | number;
  discipline?: string;
  participants?: Participant[];
  [key: string]: any;
};
TS

echo "=== Création services/courseApi.ts ==="
cat > services/courseApi.ts <<'TS'
import type { CourseData } from "../types/course";

export const getApiBase = () => {
  const fromEnv = (process.env.EXPO_PUBLIC_API_BASE || "").replace(/\/$/, "");
  if (fromEnv) return fromEnv;

  if (typeof window !== "undefined") {
    return window.location.origin.replace(/-\d+\.app\.github\.dev$/, "-8000.app.github.dev");
  }

  return "";
};

export async function fetchCourse(reunion: string, course: string): Promise<CourseData> {
  const API_BASE = getApiBase();
  const url = `${API_BASE}/api/course/${reunion}/${course}`;

  const res = await fetch(url, {
    method: "GET",
    headers: { Accept: "application/json" },
  });

  if (!res.ok) {
    throw new Error(`HTTP ${res.status}`);
  }

  const json = await res.json();

  if (!json) {
    throw new Error("Réponse vide");
  }

  return json;
}
TS

echo "=== Création hooks/useCourseScreen.ts ==="
cat > hooks/useCourseScreen.ts <<'TS'
import { useEffect, useState } from "react";
import type { CourseData } from "../types/course";
import { fetchCourse } from "../services/courseApi";

export function useCourseScreen(reunion: string, course: string) {
  const [data, setData] = useState<CourseData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      if (!reunion || !course) {
        if (!cancelled) {
          setError("Paramètres manquants");
          setLoading(false);
        }
        return;
      }

      try {
        if (!cancelled) {
          setLoading(true);
          setError("");
        }

        const json = await fetchCourse(reunion, course);

        if (!cancelled) {
          setData(json);
        }
      } catch (e: any) {
        if (!cancelled) {
          setError(e?.message || "Impossible de charger la course");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    };

    load();

    return () => {
      cancelled = true;
    };
  }, [reunion, course]);

  return { data, loading, error };
}
TS

echo "=== Création components/course/CourseHeader.tsx ==="
cat > components/course/CourseHeader.tsx <<'TSX'
import React from "react";
import { View, Text, StyleSheet } from "react-native";

export default function CourseHeader({
  reunion,
  course,
  hippodrome,
  distance,
  participantsCount,
}: {
  reunion: string;
  course: string;
  hippodrome?: string;
  distance?: string | number;
  participantsCount: number;
}) {
  return (
    <View style={styles.card}>
      <Text style={styles.main}>
        {reunion} {course}
      </Text>
      <Text style={styles.sub}>
        {hippodrome || "Hippodrome"} • {distance || "-"} • {participantsCount} partants
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: "#082b45",
    borderRadius: 18,
    padding: 16,
    marginBottom: 14,
    borderWidth: 1,
    borderColor: "rgba(130,190,255,0.16)",
  },
  main: {
    color: "#ffffff",
    fontSize: 28,
    fontWeight: "800",
    marginBottom: 4,
  },
  sub: {
    color: "#c8dced",
    fontSize: 14,
    fontWeight: "600",
  },
});
TSX

echo "=== Création components/course/CourseHorseCard.tsx ==="
cat > components/course/CourseHorseCard.tsx <<'TSX'
import React from "react";
import { View, Text, StyleSheet } from "react-native";
import type { Participant } from "../../types/course";

export default function CourseHorseCard({ horse }: { horse: Participant }) {
  return (
    <View style={styles.card}>
      <Text style={styles.title}>
        #{horse.numero} {horse.nom}
      </Text>
      <Text style={styles.text}>Carte cheval V2 à brancher ensuite</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: "#0a2b43",
    borderRadius: 18,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: "rgba(130,190,255,0.14)",
  },
  title: {
    color: "#ffffff",
    fontSize: 22,
    fontWeight: "800",
    marginBottom: 6,
  },
  text: {
    color: "#d9efff",
    fontSize: 14,
  },
});
TSX

echo
echo "=== Vérification TypeScript ==="
npx tsc --noEmit --pretty false
echo
echo "Architecture ajoutée sans modifier le comportement actuel."
