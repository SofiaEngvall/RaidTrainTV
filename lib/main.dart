import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the DefaultFirebaseOptions class
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_page.dart'; // Import the HomePage
import 'state.dart'; // Import the AppState class from state.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


final _formKey = GlobalKey<FormState>();

final String clientId = 'wgt3b63eja0ykpkesftb4s3qofqeg9';
 


Future<String?> getAppAccessToken(String clientId, String clientSecret) async {
  final response = await http.post(
    Uri.parse('https://id.twitch.tv/oauth2/token'),
    body: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'client_credentials',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data['access_token'] as String?;
  } else {
    print('Failed to get App Access Token. Status code: ${response.statusCode}');
    return null;
  }
}


Future<void> main() async {
  String clientId = 'wgt3b63eja0ykpkesftb4s3qofqeg9';
  String clientSecret = 'bxmy9v0fiiiw8a6c3p1modrqd1ojty';

  String? accessToken = await getAppAccessToken(clientId, clientSecret);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Ideal time to initialize
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 56664);
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'RaidTrain TV',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.dark().copyWith(
            primary: Color.fromARGB(255, 49, 14, 108),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

