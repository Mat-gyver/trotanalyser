# TrotAnalyser

Application d'analyse des courses de trot hippiques basée sur des indicateurs statistiques et des probabilités IA.

L'objectif est d'identifier :
- les chevaux favoris solides
- les outsiders intéressants
- les value bets (écart entre probabilité IA et probabilité PMU)

---

# Architecture

Le projet contient deux parties :

Frontend :
- React Native
- Expo Router

Backend :
- Python
- FastAPI

Structure du projet :

trotanalyser
├ start.sh
├ README.md
└ trotanalyser-app
    ├ app
    ├ backend
    │   ├ api.py
    │   └ requirements.txt
    ├ constants
    │   └ courseApiBase.ts
    ├ package.json
    └ package-lock.json

---

# Installation

Créer un environnement avec :

git clone https://github.com/Mat-gyver/trotanalyser

---

# Démarrage

Rendre le script exécutable :

chmod +x start.sh

Puis lancer l'application :

./start.sh

Le script démarre automatiquement :
- le backend FastAPI
- l'application Expo

---

# Backend

API développée avec FastAPI.

Démarrage manuel possible :

cd trotanalyser-app/backend
python3 -m uvicorn api:app --host 0.0.0.0 --port 8000

---

# Frontend

Application React Native avec Expo.

Démarrage manuel :

cd trotanalyser-app
npm install
npx expo start --tunnel

---

# Technologies utilisées

Frontend :
- React Native
- Expo
- Expo Router
- TypeScript

Backend :
- Python
- FastAPI

---

# Objectif du projet

Créer un outil d'aide à la décision pour les paris hippiques basé sur l'analyse des performances et des probabilités.

---

# Licence

Projet personnel en développement.
