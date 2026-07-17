import 'package:intl/intl.dart';

final NumberFormat ariaryFormat = NumberFormat.decimalPattern('fr');
String money(int value) => '${ariaryFormat.format(value)} Ar';
