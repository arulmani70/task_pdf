import 'package:task_pdf/src/common/common.dart';
import 'package:task_pdf/src/common/models/models.dart';
import 'package:task_pdf/src/common/constants/constansts.dart';

import 'package:logger/logger.dart';

class ProfileRepository {
  final PreferencesRepository prefRepo;
  final Logger log = Logger();

  ProfileRepository({required this.prefRepo});

  Future<UsersModel?> getUserFromPreferences() async {
    try {
      final prefs = prefRepo.getAllPreferences();

      final id = prefs[Constants.store.USER_ID];
      if (id == null || id.isEmpty) {
        log.w("ProfileRepository::No USER_ID in preferences.");
        return null;
      }

      final user = UsersModel(
        id: id,
        name: prefs[Constants.store.USER_NAME] ?? '',
        email: prefs[Constants.store.USER_EMAIL] ?? '',
        phone: prefs[Constants.store.USER_PHONE] ?? '',
        roleId: prefs[Constants.store.ROLE_ID] ?? '',
        createdAt: '',
      );

      log.i("ProfileRepository::Loaded user from preferences: $user");
      return user;
    } catch (error) {
      log.e("ProfileRepository::getUserFromPreferences::Error: $error");
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await prefRepo.clearAllPreferences();
      log.i("ProfileRepository::logout::Cleared all preferences.");
    } catch (error) {
      log.e("ProfileRepository::logout::Error: $error");
    }
  }
}
