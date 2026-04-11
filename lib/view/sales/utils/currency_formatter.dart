import 'package:intl/intl.dart';

class CurrencyFormatter {
  final _f = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  String format(double v) => _f.format(v);
}