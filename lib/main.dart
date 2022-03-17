import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/splash_screen.dart';

void main() {
  runApp(const Application());
}

class Application extends StatefulWidget {
  const Application({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ApplicationState();
  }
}

class _ApplicationState extends State<Application> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MaterialApp(
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('it', 'IT'),
          ],
          localizationsDelegates: const [
            DemoLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
            if (locale == null) return supportedLocales.first;

            for (Locale supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode ||
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }

            return supportedLocales.first;
          },
          theme: ThemeData(
              brightness: Brightness.light,
              backgroundColor: UI.windowBackgroundColorLight,
              primaryColor: UI.primaryColorLight),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            backgroundColor: UI.windowBackgroundColorDark,
            primaryColor: UI.primaryColorDark,
            cupertinoOverrideTheme: const CupertinoThemeData().copyWith(
              textTheme: const CupertinoTextThemeData(),
            ),
          ),
          home: const SplashScreen()),
    );
  }
}
