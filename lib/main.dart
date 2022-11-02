import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:pkce/pkce.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter ZITADEL Quickstart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _busy = false;
  bool _authenticated = false;
  String _username = '';
  final storage = new FlutterSecureStorage();

  Future<void> _authenticate() async {
    setState(() {
      _busy = true;
    });

    String zitadelIssuer = '[your-zitadel-issuer]';
    String zitadelClientId = '[your-client-id]';
    String webCallbackUrlScheme = 'http://localhost:4444';
    String callbackUrlScheme = 'com.example.zitadelflutter';

    final pkcePair = PkcePair.generate();
    // Construct the url
    final url = Uri.https(zitadelIssuer, '/oauth/v2/authorize', {
      'response_type': 'code',
      'client_id': zitadelClientId,
      'redirect_uri':
          kIsWeb ? '$webCallbackUrlScheme/auth.html' : '$callbackUrlScheme:/',
      'scope': 'openid profile email offline_access',
      'code_challenge': pkcePair.codeChallenge,
      'code_challenge_method': 'S256',
    });

    // Present the dialog to the user
    final result = await FlutterWebAuth2.authenticate(
        url: url.toString(), callbackUrlScheme: callbackUrlScheme);

    // Extract code from resulting url
    final code = Uri.parse(result).queryParameters['code'];

    // Use this code to get an access token
    final response =
        await http.post(Uri.https(zitadelIssuer, '/oauth/v2/token'), body: {
      'client_id': zitadelClientId,
      // 'client_secret': zitadelClientSecret,
      'redirect_uri':
          kIsWeb ? '$webCallbackUrlScheme/auth.html' : '$callbackUrlScheme:/',
      'grant_type': 'authorization_code',
      'code': code,
      'code_verifier': pkcePair.codeVerifier,
    });
    // Get the access token from the response
    final accessToken = jsonDecode(response.body)['access_token'] as String;

    // Get the refresh token from the response
    final refreshToken = jsonDecode(response.body)['refresh_token'] as String;

    // Get the id token from the response
    final idToken = jsonDecode(response.body)['id_token'] as String;

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": 'application/json; charset=UTF-8',
      "Authorization": 'Bearer $accessToken',
    };

    final userInfoResponse = await http.get(
      Uri.https(zitadelIssuer, '/oidc/v1/userinfo'),
      headers: headers,
    );

    final userJson = jsonDecode(utf8.decode(userInfoResponse.bodyBytes));

    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
    await storage.write(key: 'id_token', value: idToken);

    setState(() {
      _busy = false;
      _authenticated = true;
      _username = '${userJson['given_name']} ${userJson['family_name']}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_authenticated && !_busy)
              Text(
                'You are not authenticated.',
              ),
            if (!_authenticated && !_busy)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton.icon(
                    icon: Icon(Icons.fingerprint),
                    label: Text('login'),
                    onPressed: _authenticate),
              ),
            if (_busy)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Busy, logging in."),
                  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator())
                ],
              ),
            if (_authenticated && !_busy)
              Text(
                'Hello $_username!',
              ),
          ],
        ),
      ),
    );
  }
}
