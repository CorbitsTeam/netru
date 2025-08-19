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
  static const String media =
      'assets/images/media.jpg';
  static const String media2 =
      'assets/images/media2.jpg';
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
  static const Color grey = Color(0xFF4B5563);
  static const Color orange = Color(0xFFFF582F);
  static const Color green = Color(0xFF16A34A);
  static const Color red = Color(0xFFDC2626);
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
