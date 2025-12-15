import 'dart:convert';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class InvoiceService {
  /// Téléchargement de la facture PDF depuis le backend
  /// Retourne le chemin du fichier téléchargé pour que je l'utilise ici
  static Future<String?> downloadInvoice({
    required String invoiceBase64,
    required String filename,
  }) async {
    try {
      // Demander la permission de stockage
      final status = await _requestStoragePermission();
      if (!status.isGranted) {
        AppLogger.error(
          'InvoiceService.downloadInvoice',
          'Storage permission denied',
        );
        return null;
      }

      // Obtenir le répertoire de téléchargement
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        AppLogger.error(
          'InvoiceService.downloadInvoice',
          'Could not get download directory',
        );
        return null;
      }

      // S'assurer que le répertoire existe
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Créer le fichier avec un nom unique
      final uniqueFilename = _generateUniqueFilename(filename);
      final file = File('${directory.path}/$uniqueFilename');

      // Décoder base64 et écrire le fichier
      final pdfBytes = base64Decode(invoiceBase64);
      await file.writeAsBytes(pdfBytes);

      AppLogger.debug('Invoice downloaded: ${file.path}');
      return file.path;
    } catch (e) {
      AppLogger.error('InvoiceService.downloadInvoice', e);
      return null;
    }
  }

  /// Ouvrir le fichier PDF après téléchargement
  static Future<bool> openInvoice(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.error(
          'InvoiceService.openInvoice',
          'File does not exist: $filePath',
        );
        return false;
      }

      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        AppLogger.debug('Invoice opened: $filePath');
        return true;
      } else {
        AppLogger.error(
          'InvoiceService.openInvoice',
          'Failed to open file: ${result.message}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('InvoiceService.openInvoice', e);
      return false;
    }
  }

  /// Partager le fichier PDF
  static Future<bool> shareInvoice(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.error(
          'InvoiceService.shareInvoice',
          'File does not exist: $filePath',
        );
        return false;
      }

      final fileName = file.path.split('/').last;

      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Facture de commande - $fileName',
        text: 'Veuillez trouver ci-joint ma facture de commande.',
      );

      if (result.status == ShareResultStatus.success) {
        AppLogger.debug('Invoice shared: $filePath');
        return true;
      } else if (result.status == ShareResultStatus.dismissed) {
        AppLogger.debug('Share dismissed by user');
        return false;
      } else {
        AppLogger.error(
          'InvoiceService.shareInvoice',
          'Share failed: ${result.status}',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('InvoiceService.shareInvoice', e);
      return false;
    }
  }

  /// Supprimer un fichier facture
  static Future<bool> deleteInvoice(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.debug('Invoice deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('InvoiceService.deleteInvoice', e);
      return false;
    }
  }

  /// Demander la permission de stockage
  static Future<PermissionStatus> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Pour Android 13+
      if (await Permission.manageExternalStorage.isDenied) {
        final status = await Permission.manageExternalStorage.request();
        if (status.isDenied) {
          // Fallback sur READ_EXTERNAL_STORAGE pour versions antérieures
          return await Permission.storage.request();
        }
        return status;
      }
      return PermissionStatus.granted;
    } else if (Platform.isIOS) {
      return await Permission.photos.request();
    }
    return PermissionStatus.granted;
  }

  /// Obtenir le répertoire de téléchargement
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Utiliser le répertoire Downloads de l'application
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final downloadDir = Directory('${externalDir.path}/factures');
          return downloadDir;
        }
        // Fallback sur Documents si pas d'accès externe
        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      }
      return null;
    } catch (e) {
      AppLogger.error('InvoiceService._getDownloadDirectory', e);
      // Fallback sur Documents
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Obtenir la liste des factures téléchargées
  static Future<List<File>> getDownloadedInvoices() async {
    try {
      final directory = await _getDownloadDirectory();
      if (directory == null) return [];

      if (!await directory.exists()) return [];

      final files = directory.listSync();
      return files
          .where((f) => f is File && f.path.endsWith('.pdf'))
          .cast<File>()
          .toList();
    } catch (e) {
      AppLogger.error('InvoiceService.getDownloadedInvoices', e);
      return [];
    }
  }

  /// Générer un nom de fichier unique
  static String _generateUniqueFilename(String filename) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = filename.replaceAll('.pdf', '');
    return '${name}_$timestamp.pdf';
  }

  /// Obtenir la taille d'un fichier en format lisible
  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
