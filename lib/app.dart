import 'package:flutter/material.dart';
import 'package:aromastock/theme/app_theme.dart';
//Navigation
import 'package:aromastock/widgets/navigation/auth_wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AromaStock',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
