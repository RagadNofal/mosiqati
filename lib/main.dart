import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/user_provider.dart';
import 'package:project_assignment_e/screens/home_page.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      DevicePreview(
        enabled: /* !kReleaseMode */ false,
        builder: (context) => const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProv, _) {
          return MaterialApp(
            useInheritedMediaQuery: true,
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            debugShowCheckedModeBanner: false,
            title: 'Mosiqati',
            theme: ThemeData(
              primarySwatch: Colors.brown,
              fontFamily: 'serif',
              scaffoldBackgroundColor: const Color(0xfffbf6ef),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.brown,
              scaffoldBackgroundColor: const Color(0xff1a1008),
            ),
            themeMode: themeProv.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
