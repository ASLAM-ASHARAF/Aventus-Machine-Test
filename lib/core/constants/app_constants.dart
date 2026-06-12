
class AppConstants {
  const AppConstants._();

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String postsEndpoint = '/posts';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  
  
  static const String settingsBoxName = 'settings_box';
  static const String postsBoxName = 'posts_box';

  static const String themeModeKey = 'theme_mode';
  static const String primaryColorKey = 'primary_color';
  static const String fontFamilyKey = 'font_family';
  static const String lastSyncKey = 'last_sync_at';
}
