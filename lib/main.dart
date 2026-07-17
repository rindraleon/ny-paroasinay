import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';

void main() => runApp(const ProviderScope(child: ParishApp()));

class ParishApp extends StatelessWidget {
  const ParishApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ny Paroasinay',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr'),
        supportedLocales: const <Locale>[Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xff176b47),
          scaffoldBackgroundColor: const Color(0xfff8faf8),
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        home: const HomeScreen(),
      );
}
