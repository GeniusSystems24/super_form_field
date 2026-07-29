// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class SuperFormTranslation {
  SuperFormTranslation();

  static SuperFormTranslation? _current;

  static SuperFormTranslation get current {
    assert(
      _current != null,
      'No instance of SuperFormTranslation was loaded. Try to initialize the SuperFormTranslation delegate before accessing SuperFormTranslation.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<SuperFormTranslation> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = SuperFormTranslation();
      SuperFormTranslation._current = instance;

      return instance;
    });
  }

  static SuperFormTranslation of(BuildContext context) {
    final instance = SuperFormTranslation.maybeOf(context);
    assert(
      instance != null,
      'No instance of SuperFormTranslation present in the widget tree. Did you add SuperFormTranslation.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static SuperFormTranslation? maybeOf(BuildContext context) {
    return Localizations.of<SuperFormTranslation>(
      context,
      SuperFormTranslation,
    );
  }

  /// `This field is required`
  String get requiredMessage {
    return Intl.message(
      'This field is required',
      name: 'requiredMessage',
      desc: '',
      args: [],
    );
  }

  /// `Must be at least {count} characters`
  String minCharacters(num count) {
    return Intl.message(
      'Must be at least $count characters',
      name: 'minCharacters',
      desc: '',
      args: [count],
    );
  }

  /// `Must be at most {count} characters`
  String maxCharacters(num count) {
    return Intl.message(
      'Must be at most $count characters',
      name: 'maxCharacters',
      desc: '',
      args: [count],
    );
  }

  /// `Enter a valid email address`
  String get validEmail {
    return Intl.message(
      'Enter a valid email address',
      name: 'validEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invalid format`
  String get invalidFormat {
    return Intl.message(
      'Invalid format',
      name: 'invalidFormat',
      desc: '',
      args: [],
    );
  }

  /// `Cannot be negative`
  String get cannotBeNegative {
    return Intl.message(
      'Cannot be negative',
      name: 'cannotBeNegative',
      desc: '',
      args: [],
    );
  }

  /// `Must be at least {value}`
  String minNumber(String value) {
    return Intl.message(
      'Must be at least $value',
      name: 'minNumber',
      desc: '',
      args: [value],
    );
  }

  /// `Must be at most {value}`
  String maxNumber(String value) {
    return Intl.message(
      'Must be at most $value',
      name: 'maxNumber',
      desc: '',
      args: [value],
    );
  }

  /// `Enter a valid date`
  String get validDate {
    return Intl.message(
      'Enter a valid date',
      name: 'validDate',
      desc: '',
      args: [],
    );
  }

  /// `Must be on or after {value}`
  String minDate(String value) {
    return Intl.message(
      'Must be on or after $value',
      name: 'minDate',
      desc: '',
      args: [value],
    );
  }

  /// `Must be on or before {value}`
  String maxDate(String value) {
    return Intl.message(
      'Must be on or before $value',
      name: 'maxDate',
      desc: '',
      args: [value],
    );
  }

  /// `Search...`
  String get search {
    return Intl.message('Search...', name: 'search', desc: '', args: []);
  }

  /// `No matches`
  String get noMatches {
    return Intl.message('No matches', name: 'noMatches', desc: '', args: []);
  }

  /// `Select...`
  String get selectPlaceholder {
    return Intl.message(
      'Select...',
      name: 'selectPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Show`
  String get show {
    return Intl.message('Show', name: 'show', desc: '', args: []);
  }

  /// `Hide`
  String get hide {
    return Intl.message('Hide', name: 'hide', desc: '', args: []);
  }

  /// `Increment`
  String get increment {
    return Intl.message('Increment', name: 'increment', desc: '', args: []);
  }

  /// `Decrement`
  String get decrement {
    return Intl.message('Decrement', name: 'decrement', desc: '', args: []);
  }

  /// `Open calendar`
  String get openCalendar {
    return Intl.message(
      'Open calendar',
      name: 'openCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Select date`
  String get selectDate {
    return Intl.message('Select date', name: 'selectDate', desc: '', args: []);
  }

  /// `Pick a date from the calendar`
  String get pickDateFromCalendar {
    return Intl.message(
      'Pick a date from the calendar',
      name: 'pickDateFromCalendar',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Enabled`
  String get enabled {
    return Intl.message('Enabled', name: 'enabled', desc: '', args: []);
  }

  /// `Disabled`
  String get disabled {
    return Intl.message('Disabled', name: 'disabled', desc: '', args: []);
  }

  /// `This must be enabled to continue`
  String get mustBeEnabled {
    return Intl.message(
      'This must be enabled to continue',
      name: 'mustBeEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Select an option`
  String get selectOption {
    return Intl.message(
      'Select an option',
      name: 'selectOption',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one option`
  String get selectAtLeastOneOption {
    return Intl.message(
      'Select at least one option',
      name: 'selectAtLeastOneOption',
      desc: '',
      args: [],
    );
  }

  /// `Select at least {count} options`
  String selectAtLeastOptions(num count) {
    return Intl.message(
      'Select at least $count options',
      name: 'selectAtLeastOptions',
      desc: '',
      args: [count],
    );
  }

  /// `Select at most {count} options`
  String selectAtMostOptions(num count) {
    return Intl.message(
      'Select at most $count options',
      name: 'selectAtMostOptions',
      desc: '',
      args: [count],
    );
  }

  /// `{count} selected`
  String selectedCount(num count) {
    return Intl.message(
      '$count selected',
      name: 'selectedCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 file} other{{count} files}}`
  String fileCount(num count) {
    return Intl.plural(
      count,
      one: '1 file',
      other: '$count files',
      name: 'fileCount',
      desc: '',
      args: [count],
    );
  }

  /// `Browse`
  String get browse {
    return Intl.message('Browse', name: 'browse', desc: '', args: []);
  }

  /// ` or drag files here`
  String get dragFilesHere {
    return Intl.message(
      ' or drag files here',
      name: 'dragFilesHere',
      desc: '',
      args: [],
    );
  }

  /// `Browse or drag files here`
  String get browseOrDragFilesHere {
    return Intl.message(
      'Browse or drag files here',
      name: 'browseOrDragFilesHere',
      desc: '',
      args: [],
    );
  }

  /// `up to {size} MB`
  String upToMegabytes(double size) {
    return Intl.message(
      'up to $size MB',
      name: 'upToMegabytes',
      desc: '',
      args: [size],
    );
  }

  /// `max {count}`
  String maxFiles(num count) {
    return Intl.message(
      'max $count',
      name: 'maxFiles',
      desc: '',
      args: [count],
    );
  }

  /// `At least one file is required`
  String get atLeastOneFileRequired {
    return Intl.message(
      'At least one file is required',
      name: 'atLeastOneFileRequired',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{Attach at most 1 file} other{Attach at most {count} files}}`
  String attachAtMostFiles(num count) {
    return Intl.plural(
      count,
      one: 'Attach at most 1 file',
      other: 'Attach at most $count files',
      name: 'attachAtMostFiles',
      desc: '',
      args: [count],
    );
  }

  /// `"{name}" exceeds {size} MB`
  String fileTooLarge(String name, double size) {
    return Intl.message(
      '"$name" exceeds $size MB',
      name: 'fileTooLarge',
      desc: '',
      args: [name, size],
    );
  }

  /// `"{name}" is not an accepted type`
  String fileNotAccepted(String name) {
    return Intl.message(
      '"$name" is not an accepted type',
      name: 'fileNotAccepted',
      desc: '',
      args: [name],
    );
  }

  /// `Remove {name}`
  String removeFile(String name) {
    return Intl.message(
      'Remove $name',
      name: 'removeFile',
      desc: '',
      args: [name],
    );
  }

  /// `January`
  String get january {
    return Intl.message('January', name: 'january', desc: '', args: []);
  }

  /// `February`
  String get february {
    return Intl.message('February', name: 'february', desc: '', args: []);
  }

  /// `March`
  String get march {
    return Intl.message('March', name: 'march', desc: '', args: []);
  }

  /// `April`
  String get april {
    return Intl.message('April', name: 'april', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `June`
  String get june {
    return Intl.message('June', name: 'june', desc: '', args: []);
  }

  /// `July`
  String get july {
    return Intl.message('July', name: 'july', desc: '', args: []);
  }

  /// `August`
  String get august {
    return Intl.message('August', name: 'august', desc: '', args: []);
  }

  /// `September`
  String get september {
    return Intl.message('September', name: 'september', desc: '', args: []);
  }

  /// `October`
  String get october {
    return Intl.message('October', name: 'october', desc: '', args: []);
  }

  /// `November`
  String get november {
    return Intl.message('November', name: 'november', desc: '', args: []);
  }

  /// `December`
  String get december {
    return Intl.message('December', name: 'december', desc: '', args: []);
  }

  /// `Su`
  String get weekdaySundayNarrow {
    return Intl.message('Su', name: 'weekdaySundayNarrow', desc: '', args: []);
  }

  /// `Mo`
  String get weekdayMondayNarrow {
    return Intl.message('Mo', name: 'weekdayMondayNarrow', desc: '', args: []);
  }

  /// `Tu`
  String get weekdayTuesdayNarrow {
    return Intl.message('Tu', name: 'weekdayTuesdayNarrow', desc: '', args: []);
  }

  /// `We`
  String get weekdayWednesdayNarrow {
    return Intl.message(
      'We',
      name: 'weekdayWednesdayNarrow',
      desc: '',
      args: [],
    );
  }

  /// `Th`
  String get weekdayThursdayNarrow {
    return Intl.message(
      'Th',
      name: 'weekdayThursdayNarrow',
      desc: '',
      args: [],
    );
  }

  /// `Fr`
  String get weekdayFridayNarrow {
    return Intl.message('Fr', name: 'weekdayFridayNarrow', desc: '', args: []);
  }

  /// `Sa`
  String get weekdaySaturdayNarrow {
    return Intl.message(
      'Sa',
      name: 'weekdaySaturdayNarrow',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<SuperFormTranslation> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<SuperFormTranslation> load(Locale locale) =>
      SuperFormTranslation.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
