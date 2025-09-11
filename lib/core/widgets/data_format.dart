import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

String formatDateTimeWithDay(
  String? dateTimeString,
  BuildContext context, {
  bool isActive = true,
}) {
  try {
    DateTime dateTime = DateTime.parse(dateTimeString ?? "").toLocal();

    String locale = context.locale.languageCode;

    String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy ${isActive ? 'HH:mm a' : ''}',
      locale == 'ar' ? 'ar' : 'en',
    ).format(dateTime);

    if (locale == 'ar') {
      final arabicToEnglishDigits = {
        '٠': '0',
        '١': '1',
        '٢': '2',
        '٣': '3',
        '٤': '4',
        '٥': '5',
        '٦': '6',
        '٧': '7',
        '٨': '8',
        '٩': '9',
      };

      formattedDate =
          formattedDate.split('').map((char) {
            return arabicToEnglishDigits[char] ?? char;
          }).join();
    }

    return formattedDate;
  } catch (e) {
    return "Invalid Date Format";
  }
}
