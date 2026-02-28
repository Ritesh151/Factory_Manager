import '../entities/user_profile.dart';

abstract class UserSettingsRepository {
  Stream<UserProfile?> watchProfile(String userId);
  Future<UserProfile?> getProfile(String userId);
  Future<UserProfile> saveProfile(String userId, UserProfile profile);
}
