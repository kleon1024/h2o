import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/dao/user.dart';
import 'package:h2o/model/navigation_page.dart';
import 'package:h2o/pages/navigation_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserDao()),
            ChangeNotifierProvider(create: (_) => NavigationPageModel())
          ],
          child: MyApp(),
        ),
        supportedLocales: [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        fallbackLocale: Locale('en', 'US'),
        path: 'translations'),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    Api.initialize();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Provider.of<UserDao>(context)..setContext(context);
    Provider.of<NavigationPageModel>(context)..setContext(context);

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
