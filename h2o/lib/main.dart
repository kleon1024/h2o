import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:h2o/pages/navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        child: MyApp(),
        supportedLocales: [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        fallbackLocale: Locale('en', 'US'),
        path: 'translations'),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Flutter Demo',
        theme: ThemeData(brightness: Brightness.dark),
        home: NavigationPage());
  }
}
