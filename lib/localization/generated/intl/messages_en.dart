// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, one: 'Attach at most 1 file', other: 'Attach at most ${count} files')}";

  static String m1(count) =>
      "${Intl.plural(count, one: '1 file', other: '${count} files')}";

  static String m2(name) => "\"${name}\" is not an accepted type";

  static String m3(name, size) => "\"${name}\" exceeds ${size} MB";

  static String m4(count) => "Must be at most ${count} characters";

  static String m5(value) => "Must be on or before ${value}";

  static String m6(count) => "max ${count}";

  static String m7(value) => "Must be at most ${value}";

  static String m8(count) => "Must be at least ${count} characters";

  static String m9(value) => "Must be on or after ${value}";

  static String m10(value) => "Must be at least ${value}";

  static String m11(count) => "Enter the complete ${count}-character code";

  static String m12(name) => "Remove ${name}";

  static String m13(count) => "Select at least ${count} options";

  static String m14(count) => "Select at most ${count} options";

  static String m15(count) => "${count} selected";

  static String m16(size) => "up to ${size} MB";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "april": MessageLookupByLibrary.simpleMessage("April"),
        "atLeastOneFileRequired": MessageLookupByLibrary.simpleMessage(
            "At least one file is required"),
        "attachAtMostFiles": m0,
        "august": MessageLookupByLibrary.simpleMessage("August"),
        "browse": MessageLookupByLibrary.simpleMessage("Browse"),
        "browseOrDragFilesHere":
            MessageLookupByLibrary.simpleMessage("Browse or drag files here"),
        "cannotBeNegative":
            MessageLookupByLibrary.simpleMessage("Cannot be negative"),
        "clear": MessageLookupByLibrary.simpleMessage("Clear"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "december": MessageLookupByLibrary.simpleMessage("December"),
        "decrement": MessageLookupByLibrary.simpleMessage("Decrement"),
        "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
        "dragFilesHere":
            MessageLookupByLibrary.simpleMessage(" or drag files here"),
        "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
        "february": MessageLookupByLibrary.simpleMessage("February"),
        "fileCount": m1,
        "fileNotAccepted": m2,
        "fileTooLarge": m3,
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "increment": MessageLookupByLibrary.simpleMessage("Increment"),
        "invalidFormat": MessageLookupByLibrary.simpleMessage("Invalid format"),
        "january": MessageLookupByLibrary.simpleMessage("January"),
        "july": MessageLookupByLibrary.simpleMessage("July"),
        "june": MessageLookupByLibrary.simpleMessage("June"),
        "march": MessageLookupByLibrary.simpleMessage("March"),
        "maxCharacters": m4,
        "maxDate": m5,
        "maxFiles": m6,
        "maxNumber": m7,
        "may": MessageLookupByLibrary.simpleMessage("May"),
        "minCharacters": m8,
        "minDate": m9,
        "minNumber": m10,
        "mustBeEnabled": MessageLookupByLibrary.simpleMessage(
            "This must be enabled to continue"),
        "noMatches": MessageLookupByLibrary.simpleMessage("No matches"),
        "november": MessageLookupByLibrary.simpleMessage("November"),
        "october": MessageLookupByLibrary.simpleMessage("October"),
        "openCalendar": MessageLookupByLibrary.simpleMessage("Open calendar"),
        "otpLength": m11,
        "pickDateFromCalendar": MessageLookupByLibrary.simpleMessage(
            "Pick a date from the calendar"),
        "removeFile": m12,
        "requiredMessage":
            MessageLookupByLibrary.simpleMessage("This field is required"),
        "search": MessageLookupByLibrary.simpleMessage("Search..."),
        "selectAtLeastOneOption":
            MessageLookupByLibrary.simpleMessage("Select at least one option"),
        "selectAtLeastOptions": m13,
        "selectAtMostOptions": m14,
        "selectDate": MessageLookupByLibrary.simpleMessage("Select date"),
        "selectOption":
            MessageLookupByLibrary.simpleMessage("Select an option"),
        "selectPlaceholder": MessageLookupByLibrary.simpleMessage("Select..."),
        "selectedCount": m15,
        "september": MessageLookupByLibrary.simpleMessage("September"),
        "show": MessageLookupByLibrary.simpleMessage("Show"),
        "today": MessageLookupByLibrary.simpleMessage("Today"),
        "upToMegabytes": m16,
        "validDate": MessageLookupByLibrary.simpleMessage("Enter a valid date"),
        "validEmail":
            MessageLookupByLibrary.simpleMessage("Enter a valid email address"),
        "weekdayFridayNarrow": MessageLookupByLibrary.simpleMessage("Fr"),
        "weekdayMondayNarrow": MessageLookupByLibrary.simpleMessage("Mo"),
        "weekdaySaturdayNarrow": MessageLookupByLibrary.simpleMessage("Sa"),
        "weekdaySundayNarrow": MessageLookupByLibrary.simpleMessage("Su"),
        "weekdayThursdayNarrow": MessageLookupByLibrary.simpleMessage("Th"),
        "weekdayTuesdayNarrow": MessageLookupByLibrary.simpleMessage("Tu"),
        "weekdayWednesdayNarrow": MessageLookupByLibrary.simpleMessage("We")
      };
}
