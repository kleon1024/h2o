import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:h2o/api/api.dart';
import 'package:h2o/dao/block.dart';
import 'package:h2o/dao/node.dart';
import 'package:h2o/dao/table.dart';
import 'package:h2o/dao/team.dart';
import 'package:h2o/dao/transaction.dart';
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
            ChangeNotifierProvider(create: (_) => BlockDao()),
            ChangeNotifierProvider(create: (_) => TableDao()),
            ChangeNotifierProvider(create: (_) => TransactionDao()),
          ],
          child: MyApp(),
        ),
        supportedLocales: [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        fallbackLocale: Locale('en', 'US'),
        path: 'assets/translations'),
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
    Provider.of<BlockDao>(context)..setContext(context, globalModel);
    Provider.of<TableDao>(context)..setContext(context, globalModel);
    Provider.of<TransactionDao>(context)..setContext(context, globalModel);

    TextTheme textTheme = TextTheme(
      headline1: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 30,
      ),
      headline2: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 26,
      ),
      headline3: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      bodyText2: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 14,
      ),
      bodyText1: TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 16,
      ),
    );

    return ScreenUtilInit(
        designSize: Size(1080, 1920),
        builder: () => MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'H2O APP',
            builder: BotToastInit(), //1. call BotToastInit
            navigatorObservers: [BotToastNavigatorObserver()],
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              brightness: Brightness.light,
              accentColor: Colors.indigoAccent,
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 16,
              ),
              textTheme: textTheme,
              toggleableActiveColor: Colors.indigoAccent,
              textSelectionTheme:
                  TextSelectionThemeData(cursorColor: Colors.white),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigoAccent,
                  elevation: 0,
                ),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              accentColor: Colors.indigoAccent,
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 20,
              ),
              textTheme: textTheme,
              toggleableActiveColor: Colors.indigoAccent,
              textSelectionTheme:
                  TextSelectionThemeData(cursorColor: Colors.white),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigoAccent,
                  elevation: 0,
                ),
              ),
            ),
            home: ChangeNotifierProvider(
                create: (_) => NavigationPageModel(),
                child: NavigationPage())));
  }
}
