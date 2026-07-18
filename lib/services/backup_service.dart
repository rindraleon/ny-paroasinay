import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database_service.dart';

class BackupService {
  /// Crée une copie SQLite et ouvre la feuille de partage Android.
  static Future<void> exportAndShare() async {
    await DatabaseService.instance.close();
    final Directory directory = await getApplicationDocumentsDirectory();
    final String name =
        'ny_paroasinay_sauvegarde_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.db';
    final File target = File(path.join(directory.path, name));
    await File(await DatabaseService.instance.databasePath()).copy(target.path);
    await Share.shareXFiles(<XFile>[XFile(target.path)],
        subject: 'Sauvegarde Ny Paroasinay');
  }

  /// Sélectionne une sauvegarde .db, remplace les données locales et retourne true si réussi.
  static Future<bool> importFromPicker() async {
    final FilePickerResult? result = await FilePicker.I.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['db'],
    );
    if (result == null || result.files.single.path == null) return false;
    final File source = File(result.files.single.path!);
    await DatabaseService.instance.close();
    await source.copy(await DatabaseService.instance.databasePath());
    return true;
  }
}
