/// App Icons Constants
/// 
/// This class contains all icon paths used in the application.
/// Icons are exported from Figma and stored in assets/icons/
class AppIcons {
  AppIcons._(); // Private constructor to prevent instantiation

  // Base path for icons
  static const String _iconsPath = 'assets/icons';

  // Navbar Icons
  static const String home = '$_iconsPath/home_icon.svg';
  static const String transfer = '$_iconsPath/transfer_icon.svg';
  static const String history = '$_iconsPath/history_icon.svg';
  static const String settings = '$_iconsPath/settings_icon.svg';
  static const String profile = '$_iconsPath/profile_icon.svg';

  // Menu Icons (if different from navbar)
  static const String menu = '$_iconsPath/menu_icon.svg';
  static const String close = '$_iconsPath/close_icon.svg';

  // Additional Icons
  static const String notification = '$_iconsPath/notification_icon.svg';
  static const String search = '$_iconsPath/search_icon.svg';
  static const String filter = '$_iconsPath/filter_icon.svg';
}

