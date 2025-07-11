import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:elearn/consttants.dart';
import 'package:elearn/model/detailsProvider.dart';
import 'package:elearn/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/l10n.dart';
import 'language_constants.dart';

bool isAndroidVersionUp13 = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);

  // Comentado código do OneSignal
  // final String oneSignalAppId = "331a8c6c-3c1e-45e9-b012-049ff5f26e68";
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // OneSignal.initialize(oneSignalAppId);
  // OneSignal.Notifications.requestPermission(true);

  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(context, newLocale);
  }

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? _locale;

  setLocale(context, Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  StreamSubscription<FGBGType>? subscription;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      getAndroidVersion();
    }
    subscription = FGBGEvents.instance.stream.listen((event) {
      // Ad handling removed
    });
    super.initState();
  }

  getAndroidVersion() async {
    String? firstPart;
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    if (allInfo['version']["release"].toString().contains(".")) {
      int indexOfFirstDot = allInfo['version']["release"].indexOf(".");
      firstPart = allInfo['version']["release"].substring(0, indexOfFirstDot);
    } else {
      firstPart = allInfo['version']["release"];
    }
    int intValue = int.parse(firstPart!);
    if (intValue >= 13) {
      isAndroidVersionUp13 = true;
    } else {
      isAndroidVersionUp13 = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness:
                mode.value == false ? Brightness.light : Brightness.dark,
            statusBarIconBrightness:
                mode.value == false ? Brightness.dark : Brightness.light,
            systemNavigationBarIconBrightness:
                mode.value == false ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: comboBlackAndWhite(),
          ),
        );
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    getUserId();
    SharedPreferences.getInstance().then(
      (prefs) {
        mode.value = prefs.getBool("isDark") ?? false;
        if (prefs.getBool("isDark") == null) {
          prefs.setBool("isDark", false);
        }
      },
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
      ],
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        minTextAdapt: true,
        builder: (BuildContext context, _) => GetMaterialApp(
          locale: _locale,
          themeMode: mode.value == false ? ThemeMode.light : ThemeMode.dark,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        ),
      ),
    );
  }
}
