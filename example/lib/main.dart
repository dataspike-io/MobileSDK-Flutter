import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/dataspikemobilesdk.dart';
import 'package:dataspikemobilesdk/screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _dataspikemobilesdkPlugin = Dataspikemobilesdk();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnboardingScreen(),
    );
  }
}
