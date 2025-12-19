# Guide de Configuration Firebase pour Yoboulma

Ce guide vous explique comment configurer Firebase pour votre application Flutter.

## 📋 Prérequis

1. Un compte Google
2. Node.js installé (pour FlutterFire CLI)
3. Flutter CLI installé

## 🔧 Étapes de Configuration

### 1. Installer FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2. Se connecter à Firebase

```bash
firebase login
```

### 3. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Nommez votre projet (ex: "yoboulma")
4. Activez Google Analytics (optionnel mais recommandé)
5. Créez le projet

### 4. Générer les fichiers de configuration

Dans le répertoire racine de votre projet, exécutez :

```bash
flutterfire configure
```

Cette commande va :
- Vous demander de sélectionner votre projet Firebase
- Générer automatiquement le fichier `lib/firebase_options.dart`
- Configurer Firebase pour toutes les plateformes (Android, iOS, Web)

## 📁 Fichiers à Configurer

### ✅ Fichiers générés automatiquement

Après avoir exécuté `flutterfire configure`, ces fichiers seront créés automatiquement :

1. **`lib/firebase_options.dart`** - Configuration Firebase pour toutes les plateformes

### 📱 Configuration Android

#### Fichier : `android/app/google-services.json`

**Emplacement** : `android/app/google-services.json`

**Comment l'obtenir** :
1. Allez sur Firebase Console → Paramètres du projet → Vos applications
2. Cliquez sur l'icône Android
3. Entrez le package name : `com.example.yoboulma_app`
4. Téléchargez `google-services.json`
5. Placez-le dans `android/app/`

#### Modifier : `android/build.gradle.kts`

Ajoutez le plugin Google Services :

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### Modifier : `android/app/build.gradle.kts`

Ajoutez en bas du fichier :

```kotlin
plugins {
    // ... autres plugins
    id("com.google.gms.google-services")
}
```

### 🍎 Configuration iOS

#### Fichier : `ios/Runner/GoogleService-Info.plist`

**Emplacement** : `ios/Runner/GoogleService-Info.plist`

**Comment l'obtenir** :
1. Allez sur Firebase Console → Paramètres du projet → Vos applications
2. Cliquez sur l'icône iOS
3. Entrez le Bundle ID : `com.example.yoboulmaApp`
4. Téléchargez `GoogleService-Info.plist`
5. Placez-le dans `ios/Runner/`

### 🌐 Configuration Web

#### Modifier : `web/index.html`

Ajoutez la configuration Firebase dans la section `<head>` :

```html
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js"></script>
<script>
  const firebaseConfig = {
    apiKey: "VOTRE_API_KEY",
    authDomain: "VOTRE_PROJECT_ID.firebaseapp.com",
    projectId: "VOTRE_PROJECT_ID",
    storageBucket: "VOTRE_PROJECT_ID.appspot.com",
    messagingSenderId: "VOTRE_SENDER_ID",
    appId: "VOTRE_APP_ID"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

**Note** : Les valeurs seront automatiquement remplacées par `flutterfire configure`.

## 🔐 Configuration Firestore

### 1. Activer Firestore

1. Allez sur Firebase Console → Firestore Database
2. Cliquez sur "Créer une base de données"
3. Choisissez "Mode de production" ou "Mode test" (pour développement)
4. Sélectionnez une région (ex: `europe-west1` pour l'Europe)

### 2. Règles de sécurité Firestore

Allez dans Firestore → Règles et configurez :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false; // Seul l'admin peut supprimer
    }
    
    // Batches collection
    match /batches/{batchId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

## 📱 Configuration Firebase Authentication

### 1. Activer les méthodes d'authentification

1. Allez sur Firebase Console → Authentication
2. Cliquez sur "Commencer"
3. Activez les méthodes suivantes :
   - **Email/Password** : Pour l'authentification par email
   - **Phone** : Pour l'authentification par SMS (nécessite configuration supplémentaire)

### 2. Configuration Phone Auth (optionnel)

Pour l'authentification par téléphone :
1. Allez sur Authentication → Sign-in method → Phone
2. Activez "Phone"
3. Configurez reCAPTCHA (nécessaire pour Web)

## 🧪 Tester la Configuration

Après avoir configuré Firebase, testez avec :

```bash
flutter run
```

Vérifiez que l'application se connecte bien à Firebase sans erreurs.

## 📝 Checklist

- [ ] FlutterFire CLI installé
- [ ] Projet Firebase créé
- [ ] `flutterfire configure` exécuté
- [ ] `google-services.json` ajouté (Android)
- [ ] `GoogleService-Info.plist` ajouté (iOS)
- [ ] `index.html` configuré (Web)
- [ ] Firestore activé
- [ ] Règles Firestore configurées
- [ ] Authentication activé
- [ ] Application testée

## 🆘 Problèmes Courants

### Erreur : "FirebaseApp not initialized"
- Vérifiez que `firebase_options.dart` existe
- Vérifiez que `Firebase.initializeApp()` est appelé dans `main.dart`

### Erreur : "google-services.json not found" (Android)
- Vérifiez que le fichier est dans `android/app/`
- Vérifiez que le plugin Google Services est ajouté

### Erreur : "GoogleService-Info.plist not found" (iOS)
- Vérifiez que le fichier est dans `ios/Runner/`
- Nettoyez le build : `flutter clean && flutter pub get`

## 📚 Ressources

- [Documentation FlutterFire](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

