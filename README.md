# 🏆 Grand Quiz du RCBA – Racing Club Bû Abondant

[![RCBA](https://img.shields.io/badge/RCBA-Fiers_de_nos_couleurs-0B1D4F?style=for-the-badge&logo=football)](https://github.com/scarla28260)
[![District](https://img.shields.io/badge/District-Eure--et--Loir_28-00C2FF?style=for-the-badge)](https://foot28.fff.fr/)
[![Status](https://img.shields.io/badge/Version-Officielle_2026-F59E0B?style=for-the-badge)]()

Application web interactive et studio de création de visuels HD dédiés au **Grand Quiz Officiel du Racing Club Bû Abondant (RCBA)**.

---

## 🌟 Présentation du Projet

Ce projet a été conçu pour animer la communauté des supporters, licenciés, bénévoles et partenaires du **RCBA** sur les réseaux sociaux (**Meta Business Suite**, Facebook & Instagram) tout en offrant une expérience de jeu fluide et immersive sur le web.

### 🎮 Deux Modes en Un :
1. **Mode Joueur Interactif (Quiz Direct)** :
   * 11 questions officielles du club : fondation bicommunale Bû-Abondant, 450 licenciés, Top 5 en Eure-et-Loir, double labélisation FFF (Jeunes & Féminines), section féminine loisir, gymnase intercommunal de Bû, rituel de la buvette, affiliation District 28, tenues bleu roi et gris, gestion logistique et causerie d'avant-match.
   * **Enchaînement automatique & irréversible** : Dès le clic sur une option (A, B ou C), le choix est verrouillé sans retour arrière possible, affichant la validation et l'anecdote club, avant de passer automatiquement à la question suivante après 1,4 s.
   * **Grand Écran de Palmarès & Résultats** : Calcul du score officiel sur 11, attribution d'un rang club certifié, récapitulatif complet des 11 questions et bouton de partage formaté pour les réseaux sociaux.

2. **Mode Studio Réseaux Sociaux** :
   * Visualisation et export haute définition (1080 × 1336 px, ratio 4:5 optimisé pour Instagram et Facebook).
   * 23 visuels officiels : 11 slides Question, 11 slides Réponse avec explication, et 1 slide bilan Palmarès du Quiz.
   * Téléchargement unitaire ou en pack complet en un clic via `html2canvas`.

---

## 🎖️ Barème & Rangs Officiels du Club

| Score | Rang Attribué | Statut & Reconnaissance |
| :---: | :--- | :--- |
| **10 - 11 pts** | 🏆 **Légende du Stade** | Sang Bleu & Blanc pur ! Le club n'a aucun secret pour vous. Statut VIP au club-house ! |
| **7 - 9 pts** | ⚽ **Titulaire Indiscutable** | Une excellente culture RCBA. Toujours présent pour encourager les équipes le dimanche ! |
| **4 - 6 pts** | 🎽 **Espoir du Club** | De bonnes bases, mais quelques révisions s'imposent à la buvette autour d'une crêpe. |
| **0 - 3 pts** | 🎯 **Supporter en Rodage** | Bienvenue au RCBA ! C'est l'occasion idéale de venir voir jouer nos équipes ce week-end ! |

---

## 📁 Structure du Répertoire

```text
Quizz/
├── index.html                     # Application web interactive (Studio & Joueur)
├── quiz_data.json                 # Base de données officielle des 11 questions & anecdotes
├── POSTS_META_BUSINESS_SUITE.md   # Textes des 12 posts officiels prêts à copier-coller
├── generer_tous_les_visuels.ps1   # Script PowerShell d'automatisation des captures HD
├── assets/                        # Ressources graphiques officielles (logos RCBA, fonds, sponsors)
│   ├── fond_clean.png
│   ├── fond_modele.png
│   ├── logo_rcba.png
│   ├── logo_rcba_hd.png
│   └── sponsors/
├── fonts/                         # Typographies du club
├── visuels_quiz/                  # 23 visuels HD générés (1080x1336 px)
└── README.md                      # Documentation du projet
```

---

## 🚀 Démarrage Rapide

### Utilisation Locale
Ouvrez simplement le fichier `index.html` dans n'importe quel navigateur web moderne :
```bash
# Directement via double-clic ou en ligne de commande :
start index.html
```

### Déploiement en Ligne (GitHub Pages)
Pour rendre le quiz jouable en ligne par tous les supporters :
1. Activez **GitHub Pages** dans les paramètres du dépôt (*Settings > Pages > Branch: main > Save*).
2. Partagez l'URL publique générée (ex. `https://scarla28260.github.io/rcba-quiz/`).

---

## 🔒 Suivi d'Audience Privé (Mouchard Invisible)

Un système de comptage des vues en temps réel et discret est intégré directement dans le quiz :
* **100% invisible pour les joueurs** : Aucun badge ni compteur public n'apparaît lors des parties.
* **Comptage automatique & anti-doublon** : Chaque nouvelle session de visite est comptabilisée en tâche de fond.
* **Accès exclusif réservé au club** :
  * **Raccourci secret** : Faites **3 clics rapides** directement sur le grand titre *« LE GRAND QUIZ DU RCBA »*.
  * **Code PIN secret** : Entrez `28260` pour déverrouiller l'affichage du total des vues réelles et actualiser en direct.

---

## ⚽ Valeurs du RCBA
> **RESPECT • ENGAGEMENT • CONVIVIALITÉ • PERFORMANCE • SÉRIEUX**  
> *« Un club. Plusieurs équipes. Une seule passion. »* 💙🤍💚
