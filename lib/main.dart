import 'package:flutter/material.dart';
import 'package:shop_app_by_api/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop_App',
      theme: ThemeData.dark().copyWith(
        appBarTheme:
            const AppBarTheme(backgroundColor: Color.fromARGB(255, 31, 32, 32)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
