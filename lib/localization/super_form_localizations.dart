import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';

export 'generated/l10n.dart';

/// Stable localization helpers around the generated translation delegate.
abstract final class SuperFormLocalizations {
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        SuperFormTranslation.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];
}

extension SuperFormTranslationCalendarX on SuperFormTranslation {
  List<String> get monthNames => [
    january,
    february,
    march,
    april,
    may,
    june,
    july,
    august,
    september,
    october,
    november,
    december,
  ];

  List<String> get narrowWeekdays => [
    weekdaySundayNarrow,
    weekdayMondayNarrow,
    weekdayTuesdayNarrow,
    weekdayWednesdayNarrow,
    weekdayThursdayNarrow,
    weekdayFridayNarrow,
    weekdaySaturdayNarrow,
  ];
}
