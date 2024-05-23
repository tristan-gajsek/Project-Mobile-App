import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noise Pollution App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // theme: catppuccinTheme(catppuccin.latte),
      // darkTheme: catppuccinTheme(catppuccin.mocha),
      home: const LoginScreen(),
    );
  }
}
