# Ny Paroasinay — Saint François d’Assise

Application Android Flutter de gestion de la caisse de la paroisse de Tsararivotra Ambalavao. Son icône représente Saint François d’Assise. Elle fonctionne sans Internet : les opérations sont stockées dans une base SQLite du téléphone.

## Fonctions incluses

- Enregistrement, modification et suppression des entrées et sorties de caisse ;
- Montants en Ariary (Ar) ;
- Catégories de revenus et de dépenses, notamment **Prêtres** ;
- Tableau de bord : solde et totaux du mois ;
- Journal de caisse ;
- Rapport global et génération d’un PDF partageable (WhatsApp, e-mail, impression) ;
- Création et importation d’une sauvegarde locale des données (`.db`) ;
- Don anonyme ;
- Analyse statique, tests et compilation Android automatique avec GitHub Actions.

## Installation locale

Prérequis : Flutter stable et Android SDK.

```bash
flutter pub get
flutter create --platforms=android --org mg.tsararivotra . # une seule fois si android/ n’existe pas
dart run tool/prepare_android.dart # définit Ny Paroasinay
dart run flutter_launcher_icons # génère l’icône de Saint François
flutter run
```

Pour produire un APK :

```bash
flutter build apk --release
```

Le fichier est produit dans `build/app/outputs/flutter-apk/app-release.apk`.

## CI/CD GitHub

Le fichier [`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml) effectue automatiquement :

1. `dart format` : contrôle du formatage ;
2. `flutter analyze` : linter / analyse statique ;
3. `flutter test` : tests unitaires ;
4. `flutter build apk --release` et `flutter build appbundle --release` ;
5. dépôt des fichiers APK et AAB comme artefacts GitHub.

À chaque *push* sur `main` ou chaque Pull Request, la qualité et le build sont vérifiés. Les artefacts sont accessibles dans **Actions → Flutter CI/CD → Artifacts**.

Pour créer automatiquement une release GitHub avec l’APK et l’AAB :

```bash
git tag v1.0.0
git push origin v1.0.0
```

> Avant de publier sur Google Play, configurez une clé de signature Android (`keystore`) et les secrets GitHub correspondants. Ne placez jamais cette clé dans Git.

## Données et confidentialité

Les données sont locales au téléphone. Effectuez régulièrement des sauvegardes du téléphone. La prochaine version peut ajouter l’export PDF/CSV, une sauvegarde/restauration chiffrée et un code PIN.
