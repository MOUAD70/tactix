cd# Tactix - Application de Gestion Tactique

Ce dépôt contient le code source du projet **Tactix**, divisé en deux parties principales :
- **Back-end** : Une API REST développée avec **Laravel 12** (PHP).
- **Front-end** : Une application mobile/multiplateforme développée avec **Flutter 3.10+**.

Voici les instructions détaillées pour configurer et lancer le projet en local.

---

## 🛠️ 1. Prérequis

Assurez-vous d'avoir les outils suivants installés sur votre machine :
- **PHP** (>= 8.2)
- **Composer** (Gestionnaire de dépendances PHP)
- **Node.js & NPM** (Pour compiler certains assets front-end si nécessaire)
- **Flutter SDK** (>= 3.10.8)
- **Un émulateur** (Android / iOS) ou un navigateur web actif.

---

## ⚙️ 2. Configuration & Lancement du Back-end (API / BDD)

Le back-end utilise Laravel et une base de données **SQLite** par défaut (facile à lancer sans installer de serveur de base de données complexe).

Puisque le script d'installation a déjà été pré-configuré dans `composer.json`, l'initialisation est simplifiée. Ouvrez un terminal :

1. **Accédez au dossier back-end**
   ```bash
   cd back-end
   ```

2. **Installez les dépendances et initialisez le projet**
   Vous pouvez utiliser le script de setup prédéfini qui va installer les dépendances, créer le fichier `.env`, générer la clé, et créer la base de données :
   ```bash
   composer run setup
   ```
   *(Sinon manuellement : `composer install`, `copy .env.example .env`, `php artisan key:generate`).*

3. **Base de données et Migrations**
   Par défaut, Laravel utilise **SQLite**. Le nom et l'emplacement de la base de données correspondent au fichier `database/database.sqlite`. 
   
   Créez ce fichier vide d'abord s'il n'existe pas :
   ```bash
   touch database/database.sqlite
   ```
   
   Ensuite, pour lancer les **migrations** (ce qui va créer toutes les tables nécessaires comme users, teams, etc. dans la base de données), lancez la commande suivante :
   ```bash
   php artisan migrate
   ```
   *(Si Laravel vous demande s'il doit créer la base de données pour vous, tapez `yes`)*

4. **Démarrez le serveur local de l'API**
   ```bash
   php artisan serve
   ```
   L'API sera accessible à l'adresse suivante : `http://127.0.0.1:8000`

---

## 📱 3. Configuration & Lancement du Front-end (Flutter)

Laissez le serveur Laravel s'exécuter et ouvrez un **nouveau terminal**.

1. **Accédez au dossier front-end**
   ```bash
   cd front-end
   ```

2. **Installez les paquets (packages) Flutter**
   ```bash
   flutter pub get
   ```

3. **Lancez l'application**
   Assurez-vous qu'un émulateur est ouvert, ou qu'un navigateur Chrome est disponible, puis exécutez :
   ```bash
   flutter run
   ```

> [!NOTE] 
> **Astuce d'accès API depuis l'émulateur** :
> Si vous testez avec un **émulateur Android**, l'adresse `127.0.0.1` correspond à l'émulateur lui-même. Pour accéder à l'API Laravel qui tourne sur votre machine hôte, vous devrez vérifier que l'URL d'API de l'application Flutter pointe vers `http://10.0.2.2:8000`.
> Pour le **simulateur iOS** ou **Web**, `http://127.0.0.1:8000` fonctionne directement.

---

## 🚀 En bref au quotidien
- **Lancer l'API** : `cd back-end` puis `php artisan serve`
- **Lancer l'App Flutter** : `cd front-end` puis `flutter run`
