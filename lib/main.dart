import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smart_bachat/ui/components/bottom_sheet/my_bottom_sheet.dart';
import 'package:smart_bachat/providers/all_categories_provider.dart';
import 'package:smart_bachat/providers/home_provider.dart';
import 'package:smart_bachat/ui/screens/ui/splash_screen/splash_screen.dart';
import 'package:smart_bachat/providers/auth_provider.dart';
import 'package:smart_bachat/providers/transaction_provider.dart';
import 'package:smart_bachat/providers/reports_provider.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // var directory = await getApplicationDocumentsDirectory();
  // Hive.init(directory.path);
  WidgetsFlutterBinding.ensureInitialized(); // Add this line to initialize the binding

  // Now you can safely set preferred orientations or do other system-level initializations

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
        ChangeNotifierProvider(create: (_) => MyBottomSheetProvider()),
        ChangeNotifierProvider(create: (_) => AllCategoriesProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const MySplashScreen(),
          );
        },
      ),
    );
  }
}
