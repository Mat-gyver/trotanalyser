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
