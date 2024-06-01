import 'package:flutter/material.dart';
import 'package:project_mobile_app/screens/authentication/login.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedState = SharedState();
  sharedState.initializeMqtt('192.168.56.1', 'flutter_client');

  runApp(ChangeNotifierProvider(
    create: (context) => SharedState(),
    child: const App(),
  ));
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
      darkTheme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}
