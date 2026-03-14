const fromEnv = (process.env.EXPO_PUBLIC_API_BASE || "").replace(/\/$/, "");

export const API_BASE = fromEnv;

export function assertApiBase() {
  if (!API_BASE) {
    throw new Error(
      "EXPO_PUBLIC_API_BASE manquant. Configure l'URL publique du backend avant de lancer l'app."
    );
  }
  return API_BASE;
}
