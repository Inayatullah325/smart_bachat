import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/providers/home_provider.dart';
import 'package:smart_bachat/providers/settings_provider.dart';
import 'package:smart_bachat/services/notification_service.dart';
import 'package:smart_bachat/ui/screens/ui/splash_screen/splash_screen.dart';
import 'package:smart_bachat/providers/auth_provider.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';
import 'package:smart_bachat/providers/reports_provider.dart';
import 'package:smart_bachat/providers/notification_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_bachat/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ResponsiveSizer(
      builder: (context, orientation, ScreenType) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final settingsProvider = Provider.of<SettingsProvider>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Bachat',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            locale: settingsProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ur'),
              Locale('ar'),
              Locale('hi'),
              Locale('es'),
              Locale('fr'),
              Locale('zh'),
            ],
            home: const MySplashScreen(),
          );
        },
      ),
    );
  }
}
