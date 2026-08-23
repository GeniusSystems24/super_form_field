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
        "demoFillExamples":
            MessageLookupByLibrary.simpleMessage("Fill examples"),
        "demoFormCompletionAndSavedValuesSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "Completion and FormState.save() values"),
        "demoFormResultTitle":
            MessageLookupByLibrary.simpleMessage("Form result"),
        "demoFormSavedValuesSubtitle": MessageLookupByLibrary.simpleMessage(
            "Values received through FormState.save()"),
        "demoNotSaved": MessageLookupByLibrary.simpleMessage("Not saved"),
        "demoNotSavedYet":
            MessageLookupByLibrary.simpleMessage("Not saved yet"),
        "demoReset": MessageLookupByLibrary.simpleMessage("Reset"),
        "demoValidateAndSave":
            MessageLookupByLibrary.simpleMessage("Validate & save"),
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
        "otpBackupCodeHelper": MessageLookupByLibrary.simpleMessage(
            "Letters are normalized to uppercase."),
        "otpBackupCodeLabel":
            MessageLookupByLibrary.simpleMessage("Backup code"),
        "otpBackupCodeResultLabel":
            MessageLookupByLibrary.simpleMessage("Backup code"),
        "otpBackupSubtitle": MessageLookupByLibrary.simpleMessage(
            "Custom keyboard and formatter composition"),
        "otpBackupTitle":
            MessageLookupByLibrary.simpleMessage("Alphanumeric backup code"),
        "otpCodesSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Verification codes saved successfully."),
        "otpDemoCardSubtitle": MessageLookupByLibrary.simpleMessage(
            "SMS autofill · paste · secure PIN · completion"),
        "otpDemoCardTitle":
            MessageLookupByLibrary.simpleMessage("Super OTP Field"),
        "otpDemoEyebrow": MessageLookupByLibrary.simpleMessage(
            "OTP Field • Verification Codes"),
        "otpDemoTitle":
            MessageLookupByLibrary.simpleMessage("OTP Field Examples"),
        "otpLastCompletedLabel":
            MessageLookupByLibrary.simpleMessage("Last completed"),
        "otpLength": m11,
        "otpPinResultLabel": MessageLookupByLibrary.simpleMessage("PIN"),
        "otpPinSubtitle": MessageLookupByLibrary.simpleMessage(
            "Four digits displayed with an obscuring character"),
        "otpPinTitle":
            MessageLookupByLibrary.simpleMessage("Secure transaction PIN"),
        "otpSmsCodeLabel": MessageLookupByLibrary.simpleMessage("SMS code"),
        "otpSmsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Paste and one-time-code autofill with completion"),
        "otpSmsTitle":
            MessageLookupByLibrary.simpleMessage("SMS verification code"),
        "otpTransactionPinHelper": MessageLookupByLibrary.simpleMessage(
            "The actual digits remain available to save."),
        "otpTransactionPinLabel":
            MessageLookupByLibrary.simpleMessage("Transaction PIN"),
        "otpVerificationCodeHelper": MessageLookupByLibrary.simpleMessage(
            "A six-digit code was sent to your phone."),
        "otpVerificationCodeHint":
            MessageLookupByLibrary.simpleMessage("Enter the code sent by SMS"),
        "otpVerificationCodeLabel":
            MessageLookupByLibrary.simpleMessage("Verification code"),
        "phoneCountryRulesSubtitle": MessageLookupByLibrary.simpleMessage(
            "Compose the phone type with a prefix, mask, and pattern"),
        "phoneCountryRulesTitle":
            MessageLookupByLibrary.simpleMessage("Country-specific rules"),
        "phoneDemoCardSubtitle": MessageLookupByLibrary.simpleMessage(
            "International · country rules · formatters · Form save"),
        "phoneDemoCardTitle":
            MessageLookupByLibrary.simpleMessage("Phone Text Field"),
        "phoneDemoEyebrow":
            MessageLookupByLibrary.simpleMessage("Text Field • Phone Input"),
        "phoneDemoTitle":
            MessageLookupByLibrary.simpleMessage("Phone Field Examples"),
        "phoneInternationalHelper": MessageLookupByLibrary.simpleMessage(
            "Accepts digits, spaces, parentheses, +, and hyphens."),
        "phoneInternationalHint":
            MessageLookupByLibrary.simpleMessage("e.g. +1 (415) 555-0132"),
        "phoneInternationalResultLabel":
            MessageLookupByLibrary.simpleMessage("International"),
        "phoneInternationalSubtitle": MessageLookupByLibrary.simpleMessage(
            "Phone keyboard with common international characters"),
        "phoneInternationalTitle":
            MessageLookupByLibrary.simpleMessage("International number"),
        "phoneNumberLabel":
            MessageLookupByLibrary.simpleMessage("Phone number"),
        "phoneNumbersSavedSuccessfully": MessageLookupByLibrary.simpleMessage(
            "Phone numbers saved successfully."),
        "phoneYemenMobileHelper": MessageLookupByLibrary.simpleMessage(
            "Valid prefixes: 70, 71, 73, 77, or 78."),
        "phoneYemenMobileHint":
            MessageLookupByLibrary.simpleMessage("7X XXX XXXX"),
        "phoneYemenMobileInvalid": MessageLookupByLibrary.simpleMessage(
            "Enter a valid Yemeni mobile number."),
        "phoneYemenMobileLabel":
            MessageLookupByLibrary.simpleMessage("Yemen mobile number"),
        "phoneYemenResultLabel": MessageLookupByLibrary.simpleMessage("Yemen"),
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
