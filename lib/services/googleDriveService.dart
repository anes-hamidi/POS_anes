import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http show Client;

class GoogleDriveService {
  // ✅ Correct initialization
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      drive
          .DriveApi
          .driveFileScope, // ✅ same as "https://www.googleapis.com/auth/drive.file"
    ],
  );

  GoogleSignInAccount? _currentUser;
  http.Client? _authClient;

  /// Initialize and try silent login
  Future<void> initialize() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _refreshAuthClient();
      }
    } catch (e) {
      print("⚠️ Silent sign-in failed: $e");
    }
  }

 Future<void> _refreshAuthClient() async {
  try {
    if (_currentUser != null) {
      _authClient = await _currentUser!.authHeaders
          .then((headers) => _googleSignIn.authenticatedClient());
      if (_authClient == null) {
        print("⚠️ Authenticated client is null");
      }
    } else {
      print("⚠️ No current user to refresh auth client for");
      _authClient = null;
    }
  } catch (e) {
    print("⚠️ Failed to refresh auth client: $e");
    _authClient = null;
  }
}


  /// Ensure user signs in
  Future<void> ensureSignedIn() async {
    if (_currentUser == null) {
      try {
        _currentUser = await _googleSignIn.signIn();
        if (_currentUser != null) {
          await _refreshAuthClient();
        }
      } catch (e) {
        print("⚠️ Sign-in failed: $e");
      }
    }
  }

  /// Get Drive API instance
  Future<drive.DriveApi?> _getDriveApi() async {
    if (_authClient == null) {
      await ensureSignedIn();
    }
    return _authClient != null ? drive.DriveApi(_authClient!) : null;
  }

  /// Upload backup
  Future<bool> uploadBackup(
    File backupFile, {
    String backupName = 'pos_backup.zip',
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    try {
      final media = drive.Media(backupFile.openRead(), backupFile.lengthSync());
      final driveFile = drive.File()..name = backupName;

      final result = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );
      print("✅ Backup uploaded successfully: ${result.name} (${result.id})");
      return true;
    } catch (e) {
      print("❌ Upload failed: $e");
      print("❌ Upload failed: ${e.toString()}");
      return false;
    }
  }

  /// Download backup
  Future<File?> downloadBackup(
    String savePath, {
    String backupName = 'pos_backup.zip',
  }) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    try {
      final fileList = await driveApi.files.list(
        q: "name='$backupName'",
        spaces: 'drive',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        print("⚠️ No backup found with name: $backupName");
        return null;
      }

      final file = fileList.files!.first;
      final fileId = file.id!;
      print('fileId: $fileId');
      final media =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final saveFile = File(savePath);
      final outputStream = saveFile.openWrite();
      await media.stream.pipe(outputStream);
      await outputStream.close();

      print("✅ Backup downloaded to $savePath");
      if (saveFile.lengthSync() == 0) {
        print("❌ Downloaded file is empty");
        return null;
      }
      return saveFile;
    } catch (e) {
      print("❌ Download failed: $e");
      print("❌ Download failed: ${e.toString()}");
      return null;
    }
  }
}
