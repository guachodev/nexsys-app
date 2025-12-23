import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nexsys_app/core/database/database.dart';
import 'package:nexsys_app/features/auth/presentation/presentation.dart';
import 'package:nexsys_app/features/lecturas/data/data.dart';

enum LocalAdminMessageType { success, error }

class LocalAdminMessage {
  final String text;
  final LocalAdminMessageType type;

  LocalAdminMessage(this.text, this.type);
}

final localAdminProvider =
    StateNotifierProvider<LocalAdminNotifier, LocalAdminState>((ref) {
      final lecturasRepository = LecturasRepositoryImpl();
      final authState = ref.watch(authProvider);
      return LocalAdminNotifier(
        lecturasRepository: lecturasRepository,
        userId: authState.user!.id,
      );
    });

class LocalAdminNotifier extends StateNotifier<LocalAdminState> {
  final LecturasRepositoryImpl lecturasRepository;
  final int userId;

  LocalAdminNotifier({required this.lecturasRepository, required this.userId})
    : super(LocalAdminState()) {
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final dbFile = await DatabaseProvider.getDatabaseFile();
    final sizeMb = (await dbFile.length()) / (1024 * 1024);

    state = state.copyWith(dbSizeMb: sizeMb);
  }

  Future<void> createBackup() async {
    state = state.copyWith(isLoading: true, message: null);

    try {
      final dbFile = await DatabaseProvider.getDatabaseFile();

      /// 1️⃣ Validar existencia
      if (!await dbFile.exists()) {
        state = state.copyWith(
          message: LocalAdminMessage(
            'La base de datos no existe en el dispositivo',
            LocalAdminMessageType.error,
          ),
        );
        return;
      }

      final filename = DatabaseProvider.backupFilename();
      final bytes = await dbFile.readAsBytes();

      /// 2️⃣ Guardar con SAF
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Selecciona dónde guardar tu backup',
        fileName: filename,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      /// 3️⃣ Usuario canceló
      if (outputPath == null) {
        state = state.copyWith(
          message: LocalAdminMessage(
            'Backup cancelado por el usuario',
            LocalAdminMessageType.error,
          ),
        );
        return;
      }

      /// 4️⃣ Éxito
      state = state.copyWith(
        message: LocalAdminMessage(
          'Backup guardado correctamente',
          LocalAdminMessageType.success,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        message: LocalAdminMessage(
          'Error inesperado al crear el backup',
          LocalAdminMessageType.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> recoverAndGetPendingSync() async {
    state = state.copyWith(isLoading: true);
    try {
      final total = await lecturasRepository.recoverAndGetPendingSync(userId);
      state = state.copyWith(
        message: LocalAdminMessage(
          '$total - Lecturas recuperadas correctamente.',
          LocalAdminMessageType.success,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        message: LocalAdminMessage(
          'Error al recuperar lecturas.',
          LocalAdminMessageType.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clearLocalData() async {
    state = state.copyWith(isLoading: true, message: null);

    try {
      await DatabaseProvider.clearAllTables();

      state = state.copyWith(
        message: LocalAdminMessage(
          'Datos locales eliminados correctamente',
          LocalAdminMessageType.success,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        message: LocalAdminMessage(
          'Error al limpiar datos locales',
          LocalAdminMessageType.error,
        ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> clearImages() async {
    state = state.copyWith(isLoading: true);
    try {
      //await DatabaseProvider.clearImages();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

class LocalAdminState {
  final bool isLoading;
  final double dbSizeMb;
  final int imageCount;
  final String dbName;
  final int migrationVersion;
  final LocalAdminMessage? message;

  LocalAdminState({
    this.isLoading = false,
    this.dbSizeMb = 0,
    this.imageCount = 0,
    this.dbName = 'local.db',
    this.migrationVersion = 1,
    this.message,
  });

  LocalAdminState copyWith({
    bool? isLoading,
    double? dbSizeMb,
    int? imageCount,
    String? dbName,
    int? migrationVersion,
    LocalAdminMessage? message,
  }) {
    return LocalAdminState(
      isLoading: isLoading ?? this.isLoading,
      dbSizeMb: dbSizeMb ?? this.dbSizeMb,
      imageCount: imageCount ?? this.imageCount,
      dbName: dbName ?? this.dbName,
      migrationVersion: migrationVersion ?? this.migrationVersion,
      message: message,
    );
  }
}
