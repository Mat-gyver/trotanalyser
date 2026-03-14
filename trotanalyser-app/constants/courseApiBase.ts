import Constants from "expo-constants";

const PROD_API_BASE = process.env.EXPO_PUBLIC_API_BASE?.trim();

const getDevApiBase = () => {
  const debuggerHost = Constants.expoConfig?.hostUri;

  if (debuggerHost) {
    const host = debuggerHost.split(":").shift();
    return `http://${host}:8000`;
  }

  return "http://localhost:8000";
};

export const API_BASE = PROD_API_BASE || getDevApiBase();
