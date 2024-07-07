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
