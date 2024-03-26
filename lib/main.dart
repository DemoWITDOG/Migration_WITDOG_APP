import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:testing_pet/provider/auth_provider.dart';
import 'package:testing_pet/provider/pet_provider.dart';
import 'package:testing_pet/screens/auth/login_screen.dart';
import 'package:testing_pet/screens/auth/tab_home_screen.dart';
import 'package:testing_pet/screens/auth/tab_login_screen.dart';
import 'package:testing_pet/widgets/service/DeviceInfoService.dart';
import 'package:testing_pet/widgets/service/signalling_service.dart';


Future<void> main() async {
  KakaoSdk.init(nativeAppKey: '95a35ff740dfd9a4092ae9857cd62d2c');
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko-KR', null);

  await Supabase.initialize(
    url: 'https://fnjsdxnejydzzlievpie.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZuanNkeG5lanlkenpsaWV2cGllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDMyMTMwMjgsImV4cCI6MjAxODc4OTAyOH0.YuPhXNFkhfcLtU_NLg3gexiX9FORcQEqmy_BOGZw78Q',
  );

  String deviceId = await DeviceInfoService.getDeviceId();
  AuthProvider authProvider = AuthProvider();
  await authProvider.saveDeviceIdToSupabase(deviceId);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
/*
  final String websocketUrl = 'ws://192.168.0.18:5000';
  final String selfCallerID = Random().nextInt(999999).toString().padLeft(6, '0');

*/

  @override
  Widget build(BuildContext context) {
/*    SignallingService.instance.init(
      websocketUrl: websocketUrl,
      selfCallerId: selfCallerID,
    );*/

    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return MaterialApp(
      localizationsDelegates: [
        //GlobalMaterialLocalizations - 안드로이드
        //GlobalCupertinoLocalizations - IOS
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko','KO'),
        const Locale('en','US'),
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PetProvider()),
        ],
        child: isTablet ? TabHomeScreen(petIdentity : '') : LoginScreen(),
      ),
      routes: {
        '/login': (context) => isTablet ? TabLoginScreen() : LoginScreen(),
      },
    );
  }
}