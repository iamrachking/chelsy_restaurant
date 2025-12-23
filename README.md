# CHELSY Restaurant - Application Mobile

Application Flutter pour le restaurant CHELSY avec intégration complète de l'API backend.

## Groupe 9 (Membres)
```
LAWINGNI Abdoul Rachard: iamrachking
SEHLIN Divin: DivinSln
AHOUANDJINOU Chelsy
```

## 📱 Présentation de l'Application

**CHELSY Restaurant** est une solution mobile moderne conçue pour offrir une expérience gastronomique fluide et intuitive. L'application permet aux clients de découvrir la carte, de gérer leurs commandes et d'interagir avec le restaurant en temps réel.

### ✨ Fonctionnalités Clés
* **Carte Interactive :** Exploration des plats par catégories avec recherche filtrée.
* **Gestion du Panier :** Ajout rapide, modification des quantités et calcul automatique du total.
* **Suivi de Commande :** Historique complet et statuts en temps réel (En préparation, Prêt, Livré).
* **Profil Utilisateur :** Gestion des adresses de livraison, des favoris et des informations personnelles.
* **Paiement Intégré :** Support de Stripe pour des transactions sécurisées.

### 🎨 Identité Visuelle
L'interface a été soigneusement conçue pour refléter l'ambiance chaleureuse du restaurant :
* **Couleurs :** Une palette élégante de **Marron Foncé** (#301911) et de **Beige Clair** (#FCF6EB).
* **Design :** Utilisation de Material 3 avec des composants arrondis (12px) pour une esthétique moderne et accueillante.


## 🚀 Installation

### 1. Cloner le projet

```bash
git clone  https://github.com/IFRI-DevMobile/chelsy_restaurant.git
cd chelsy_restaurant
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 4. Lancer l'application

```bash
# Pour Android
flutter run

# Pour iOS
flutter run -d ios

# Pour un appareil spécifique
flutter devices
flutter run -d <device-id>
```


### Structure des dossiers

```
lib/
├── core/           # Services, constantes, utilitaires
├── data/           # Modèles et repositories
└── presentation/   # Controllers et UI
```

## Commandes Utiles

```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Nettoyer le projet
flutter clean
flutter pub get

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

## Contribution

1. Créer une branche pour votre fonctionnalité
2. Commiter vos changements
3. Pousser vers la branche
4. Créer une Pull Request


