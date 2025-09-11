import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_shared_preferences.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(_getInitialLocale()));
  static Locale _getInitialLocale() {
    final savedLocale = AppPreferences().getData(AppConstants.localeKey);
    if (savedLocale == 'ar') {
      return const Locale('ar');
    } else {
      return const Locale('en'); // Default language
    }
  }

  Future<void> changeLocale(Locale newLocale) async {
    await AppPreferences().setData(
      AppConstants.localeKey,
      newLocale.languageCode,
    );

    try {
      // final context = navigatorKey.currentContext;
      // if (context != null) {
      //   await EasyLocalization.of(context)?.setLocale(newLocale);
      // }
    } catch (e, s) {
      debugPrint('❗️Failed to set locale: $e');
      debugPrintStack(stackTrace: s);
    }

    emit(LocaleState(newLocale));
  }

  Future<void> toggleLocale() async {
    final newLocale =
        state.locale.languageCode == 'en'
            ? const Locale('ar')
            : const Locale('en');
    await changeLocale(newLocale);
  }
}
