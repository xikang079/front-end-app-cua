// apps/config/format_vnd.dart
import 'package:intl/intl.dart';

String formatCurrency(double value) {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
  return formatter.format(value);
}

String formatInputCurrency(String value) {
  value = value.replaceAll(',', '');
  if (value.isEmpty) return '';
  final formatter = NumberFormat('#,###');
  return formatter.format(double.parse(value));
}

String formatNumberWithoutSymbol(double value) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return formatter.format(value);
}

String formatWeightInput(String input) {
  return input.replaceAll(',', '.');
}

String removeDiacritics(String str) {
  var withDia =
      'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđ';
  var withoutDia =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  for (int i = 0; i < withDia.length; i++) {
    str = str.replaceAll(withDia[i], withoutDia[i]);
  }
  return str;
}
