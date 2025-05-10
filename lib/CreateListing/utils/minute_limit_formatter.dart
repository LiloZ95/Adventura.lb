import 'package:flutter/services.dart';

class TimeFormatStrictFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    String result = '';

    // First digit (hour)
    if (newText.length >= 1) {
      result += newText[0];
    }

    // Second digit (hour)
    if (newText.length >= 2) {
      final firstHourDigit = newText[0];
      final secondHourDigit = newText[1];

      if (firstHourDigit == '1' && int.parse(secondHourDigit) > 2) {
        result += '2'; // max allowed with first digit 1
      } else {
        result += secondHourDigit;
      }
    }

    // Add colon
    if (newText.length >= 3) {
      result += ':';

      // First digit (minute)
      final firstMinuteDigit = newText[2];
      result += int.parse(firstMinuteDigit) > 5 ? '5' : firstMinuteDigit;
    }

    // Second digit (minute)
    if (newText.length >= 4) {
      result += newText[3];
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
