import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/team.dart';
import 'package:h2o/dao/user.dart';
import 'package:h2o/model/global.dart';
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
            ChangeNotifierProvider(create: (_) => GlobalModel()),
            ChangeNotifierProvider(create: (_) => UserDao()),
            ChangeNotifierProvider(create: (_) => TeamDao()),
            ChangeNotifierProvider(create: (_) => NodeDao()),
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
    final globalModel = Provider.of<GlobalModel>(context)..setContext(context);
    Provider.of<UserDao>(context)..setContext(context, globalModel);
    Provider.of<TeamDao>(context)..setContext(context, globalModel);
    Provider.of<NodeDao>(context)..setContext(context, globalModel);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Flutter Demo',
        theme: ThemeData(brightness: Brightness.dark),
        home: ChangeNotifierProvider(
            create: (_) => NavigationPageModel(), child: NavigationPage()));
  }
}
