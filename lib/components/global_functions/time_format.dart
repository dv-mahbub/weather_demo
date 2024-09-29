import 'package:intl/intl.dart';

String formateTimeOnly(String? dateTimeString) {
  if (dateTimeString != null) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat formatter = DateFormat('haa');
      String formattedTime = formatter.format(dateTime);
      return formattedTime;
    } catch (e) {
      return '';
    }
  } else {
    return '';
  }
}
