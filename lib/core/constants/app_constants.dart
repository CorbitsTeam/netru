import 'dart:ui';

class AppAssets {
  static const String mainLogo =
      'assets/images/mainLogo.png';
  static const String imageProfile =
      'assets/images/imageProfile.jpg';
  static const String newsImages =
      'assets/images/newsImages.jpg';
  static const String newsImage2 =
      'assets/images/newsImage2.jpg';
  static const String newsImage3 =
      'assets/images/newsImage3.jpg';
}

class AppIcons {
  static const String alarm =
      "assets/icons/alarm.svg";
  static const String circle =
      "assets/icons/circle.svg";
  static const String ratio =
      "assets/icons/ratio.svg";
}

class AppColors {
  static const Color primaryColor =
      Color(0xFF002768);
}

class AppConstants {
  static const String appName = 'My App';
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar')
  ];
  static const String localeKey = 'app_locale';
  static const String themeKey = 'app_theme';
}
