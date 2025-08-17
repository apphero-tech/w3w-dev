# What3Words Salesforce Integration

Une intégration complète de l'API what3words dans Salesforce avec carte interactive Leaflet.js.

## 🎯 Fonctionnalités

### Carte Interactive Leaflet
- **Carte Leaflet.js** avec tuiles OpenStreetMap
- **Survol en temps réel** : affichage des 3 mots what3words au survol de la souris
- **Clic pour redirection** : ouverture automatique de w3w.co avec l'adresse
- **Debouncing** : optimisation des appels API (500ms)
- **Interface SLDS native** : design Lightning intégré

### API what3words
- **Endpoint AutoSuggest** : suggestions en temps réel pour saisie partielle
- **Endpoint Convert-to-3WA** : conversion coordonnées → 3 mots (limité par quota gratuit)
- **Gestion d'erreurs** : affichage des erreurs de quota et timeouts
- **Tests unitaires** : couverture Apex à 89%

## 🏗️ Architecture Technique

### Apex Classes
- **`What3Words.cls`** : classe principale d'intégration API
  - `getAutoSuggest(String input, String clipToCountry)` : suggestions what3words
  - `getWhat3WordsFromCoords(Double lat, Double lng)` : conversion coordonnées
  - `getWhat3WordsAddress(Double lat, Double lng)` : méthode complète avec métadonnées
- **`What3WordsTest.cls`** : tests unitaires avec mocks HTTP

### Lightning Web Component
- **`what3words`** : composant carte interactive
  - Chargement dynamique des ressources Leaflet depuis Static Resources
  - Gestion des événements de carte (mousemove, click)
  - Interface utilisateur SLDS native
  - Debouncing des appels API

### Configuration Sécurité
- **CSP Trusted Sites** :
  - `https://api.what3words.com` : API what3words
  - `https://tile.openstreetmap.org` : tuiles de carte
- **Static Resources** :
  - `leafletJS` : bibliothèque Leaflet.js
  - `leafletCSS` : styles Leaflet
  - `leafletImages` : icônes et images Leaflet

## 🚀 Déploiement

### Prérequis
1. **Org Salesforce** avec Lightning Experience
2. **Clé API what3words** : `ISDZLT5G` (plan gratuit)
3. **Permissions** : accès aux Apex classes et LWC

### Étapes de déploiement
```bash
# 1. Cloner le repository
git clone https://github.com/apphero-tech/w3w-dev.git
cd w3w-dev

# 2. Authentification Salesforce
sf org login web --alias w3w-dev

# 3. Déployer les métadonnées
sf project deploy start --target-org w3w-dev

# 4. Exécuter les tests
sf apex test run --target-org w3w-dev --test-level RunLocalTests
```

### Configuration post-déploiement
1. **Vérifier les Remote Site Settings** :
   - Setup → Remote Site Settings
   - Confirmer que `https://api.what3words.com` est actif

2. **Ajouter le composant à une page** :
   - App Builder → Edit Page
   - Ajouter le composant `what3words`
   - Save & Activate

3. **Permissions utilisateur** :
   - Setup → Profiles → System Administrator
   - Tab Settings → What3WordsTest → Default On

⚠️ **ÉTAPE CRITIQUE** : Activez les permissions d'onglet dans Setup → Profiles → System Administrator → Tab Settings

## 📊 Couverture de Tests

- **What3WordsTest.cls** : 8 tests unitaires
- **Couverture Apex** : 89% (What3Words.cls)
- **Mocks HTTP** : simulation complète des réponses API
- **Tests d'erreurs** : validation des limites et exceptions

## 🔧 Utilisation

### Interface Utilisateur
1. **Ouvrir la page** avec le composant what3words
2. **Survoler la carte** → voir les coordonnées et 3 mots en temps réel
3. **Cliquer n'importe où** → ouverture de w3w.co avec l'adresse

### Intégration Apex
```apex
// AutoSuggest
List<What3Words.AutoSuggestItem> suggestions = What3Words.getAutoSuggest('filled.count.so', 'FR');

// Conversion coordonnées
String words = What3Words.getWhat3WordsFromCoords(48.8584, 2.2945);
// Résultat : "remplir.compter.savon"
```

## ⚠️ Limitations Connues

### Quota API Gratuit
- **convert-to-3wa** : limité à ~25 requêtes/jour avec la clé `ISDZLT5G`
- **autosuggest** : plus généreux mais également limité
- **Solution** : upgrade vers un plan payant pour usage intensif

### Ressources Externes
- **Leaflet CDN** : dépendance aux Static Resources (pas de CDN externe)
- **OpenStreetMap** : dépendance aux tuiles externes (peut être lent)

## 🔄 Versions

### v1.0 (Actuel)
- Carte interactive Leaflet avec API temps réel
- AutoSuggest et conversion coordonnées
- Interface SLDS native
- Tests unitaires complets

### Roadmap
- [ ] Cache local des résultats what3words
- [ ] Support multi-langues
- [ ] Intégration avec les objets Salesforce standard
- [ ] Mode offline avec données pré-calculées

## 📞 Support

- **Repository** : https://github.com/apphero-tech/w3w-dev.git
- **API what3words** : https://developer.what3words.com/
- **Documentation Salesforce** : https://developer.salesforce.com/

## 📄 License

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

---

**Développé avec ❤️ pour la communauté Salesforce**