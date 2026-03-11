export const API_BASE =
process.env.EXPO_PUBLIC_API_BASE ||
window.location.origin.replace(/-\d+\.app\.github\.dev$/, "-8000.app.github.dev");
