import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

/// Zitadel url + client id.
/// you can replace String.fromEnvironment(*) calls with the actual values
/// if you don't want to pass them dynamically.
final zitadelIssuer = Uri.parse(const String.fromEnvironment('zitadel_url'));
const zitadelClientId = String.fromEnvironment('zitadel_client_id');

/// This should be the app's bundle id.
const callbackUrlScheme = 'com.zitadel.zitadelflutter';

/// This will be the current url of the page + /auth.html added to it.
final baseUri = Uri.base;
final webCallbackUrl = Uri.base.replace(path: 'auth.html');

/// for web platforms, we use http://website-url.com/auth.html
///
/// for mobile platforms, we use `com.zitadel.zitadelflutter:/`
final redirectUri =
    kIsWeb ? webCallbackUrl : Uri(scheme: callbackUrlScheme, path: '/');

final userManager = OidcUserManager.lazy(
  discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(zitadelIssuer),
  clientCredentials:
      const OidcClientAuthentication.none(clientId: zitadelClientId),
  store: OidcDefaultStore(),
  settings: OidcUserManagerSettings(
    redirectUri: redirectUri,
    // the same redirectUri can be used as for post logout too.
    postLogoutRedirectUri: redirectUri,
    scope: ['openid', 'profile', 'email', 'offline_access'],
  ),
);
late Future<void> initFuture;

void main() {
  initFuture = userManager.init();
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
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        // Show a loading widget while the app is initializing.
        // This can be used to show a splash screen for example.
        return FutureBuilder(
          future: initFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorWidget(snapshot.error.toString());
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Material(
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }
            return child!;
          },
        );
      },
      home: const MyHomePage(title: 'Flutter ZITADEL Quickstart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _busy = false;
  Object? latestError;

  /// Test if there is a logged in user.
  bool get _authenticated => _currentUser != null;

  /// To get the access token.
  String? get accessToken => _currentUser?.token.accessToken;

  /// To get the id token.
  String? get idToken => _currentUser?.idToken;

  /// To access the claims.
  String? get _username {
    final currentUser = _currentUser;
    if (currentUser == null) {
      return null;
    }
    final claims = currentUser.aggregatedClaims;
    return '${claims['given_name']} ${claims['family_name']}';
  }

  OidcUser? get _currentUser => userManager.currentUser;

  Future<void> _authenticate() async {
    setState(() {
      latestError = null;
      _busy = true;
    });
    try {
      final user = await userManager.loginAuthorizationCodeFlow();
      if (user == null) {
        //it wasn't possible to login the user.
        return;
      }
    } catch (e) {
      latestError = e;
    }
    setState(() {
      _busy = false;
    });
  }

  Future<void> _logout() async {
    setState(() {
      latestError = null;
      _busy = true;
    });
    try {
      await userManager.logout();
    } catch (e) {
      latestError = e;
    }
    setState(() {
      _busy = false;
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
            if (latestError != null)
              ErrorWidget(latestError!)
            else ...[
              if (_busy)
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Busy, logging in."),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              else ...[
                if (_authenticated) ...[
                  Text(
                    'Hello $_username!',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _logout,
                      child: const Text('Logout'),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'You are not authenticated.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Login'),
                      onPressed: _authenticate,
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
