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
