<div align="center">

# 💶 Suivi de Dépenses

**Application mobile Flutter de gestion des dépenses personnelles — entièrement en français.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-6750A4?logo=material-design&logoColor=white)
![License](https://img.shields.io/badge/Licence-MIT-green)
![Analyse](https://img.shields.io/badge/flutter%20analyze-0%20issues-brightgreen)

</div>

---

## Aperçu

Suivi de Dépenses est une application mobile **iOS & Android** construite avec Flutter, qui permet de gérer ses finances personnelles de manière simple et visuelle. Toute l'interface est en **français**, avec une devise **Euro (€)**.

### Fonctionnalités principales

- **Tableau de bord** — totaux du jour, de la semaine et du mois avec un header glassmorphique animé
- **Ajout / Modification de dépenses** — formulaire élégant avec saisie du montant, catégorie et date
- **Rapports visuels** — graphique circulaire par catégorie + graphique en barres hebdomadaire
- **Budget mensuel** — jauge de progression animée, alerte dépassement, solde restant
- **Thème clair / sombre** — Material You (Material 3) avec palette indigo-violet personnalisée
- **Persistance locale** — base de données SQLite (sqflite) + SharedPreferences pour le budget
- **0 warning d'analyse** — code propre, lints de production activés

---

## Captures d'écran

| Accueil | Ajouter | Rapports | Budget |
|:---:|:---:|:---:|:---:|
| Dashboard glassmorphique | Formulaire avec header gradient | Pie + Bar charts | Jauge circulaire animée |

---

## Architecture

```
lib/
├── core/
│   └── app_theme.dart          # Thème Material 3 light/dark centralisé
├── data/
│   └── database_helper.dart    # Singleton SQLite — CRUD dépenses
├── models/
│   └── expense.dart            # Modèle Expense + enum ExpenseCategory
├── providers/
│   ├── expense_provider.dart   # ChangeNotifier — source de vérité des dépenses
│   └── budget_provider.dart    # ChangeNotifier — budget mensuel (SharedPreferences)
├── screens/
│   ├── main_shell.dart         # Shell principal avec NavigationBar
│   ├── home_screen.dart        # Onglet Accueil
│   ├── add_edit_expense_screen.dart  # Onglet Ajouter / écran Modifier
│   ├── reports_screen.dart     # Onglet Rapports
│   └── budget_screen.dart      # Onglet Budget
└── main.dart                   # Initialisation, locale fr_FR, MultiProvider
```

**Principes respectés :**
- UI passive — aucune logique métier dans `build()`
- Providers injectés via `MultiProvider` à la racine
- `List.unmodifiable` sur les getters publics
- Optimistic delete pour une suppression instantanée
- `NumberFormat` instancié une seule fois (`static final`)
- `context.mounted` vérifié après tous les `await`

---

## Stack technique

| Couche | Technologie |
|---|---|
| Framework | Flutter 3.x + Dart 3.x |
| UI Design | Material 3, glassmorphism, gradients |
| État | Provider (ChangeNotifier) |
| Base de données | sqflite (SQLite local) |
| Préférences | shared_preferences |
| Graphiques | fl_chart |
| Formatage | intl (locale `fr_FR`) |
| IDs | uuid v4 |
| Linting | flutter_lints + règles production |

---

## Installation

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- Dart ≥ 3.0
- Un émulateur ou appareil physique iOS / Android

### Lancer le projet

```bash
# Cloner le dépôt
git clone https://github.com/<ton-username>/expense_tracker.git
cd expense_tracker

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Compiler en release

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

---

## Qualité du code

```bash
# Analyse statique
flutter analyze

# Corrections automatiques
dart fix --apply
```

> Résultat attendu : **No issues found!**

---

## Catégories de dépenses

| Emoji | Catégorie | Couleur |
|:---:|---|---|
| 🍔 | Alimentation | Rouge corail |
| ✈️ | Transport | Vert menthe |
| 🛍️ | Achats | Orange |
| 🧾 | Factures | Violet |
| 📦 | Divers | Gris bleu |

---

## Licence

Ce projet est distribué sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

<div align="center">
Fait avec ❤️ et Flutter
</div>
