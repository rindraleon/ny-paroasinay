import 'dart:io';

/// Définit le nom affiché de l’application Android.
/// À exécuter après : flutter create --platforms=android .
void main() {
  final File manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    stderr.writeln('Android absent. Exécutez d’abord : flutter create --platforms=android .');
    exitCode = 1;
    return;
  }
  final String content = manifest.readAsStringSync();
  final String updated = content.replaceFirst(RegExp(r'android:label="[^"]*"'), 'android:label="Ny Paroasinay"');
  manifest.writeAsStringSync(updated);
  stdout.writeln('Nom Android défini : Ny Paroasinay');
}
