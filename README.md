# zitadel_flutter

This project is a starting point for a Flutter application with ZITADEL integration.

## Deploy your own

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fzitadel%2Fzitadel_flutter)

To deploy your page with vercel, go to settings (Build & Development Settings), then override your build command to (make sure to replace `[zitadel-url]` and `[zitadel-client-id]`):

```bash
flutter/bin/flutter build web --dart-define zitadel_url=[zitadel-url] --dart-define zitadel_client_id=[zitadel-client-id]
```

output directory is

```bash
build/web
```

install command is

```bash
if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && ls && flutter/bin/flutter doctor && flutter/bin/flutter clean && flutter/bin/flutter config --enable-web
```

then add your redirect uri in ZITADEL console. It should look like this `https://your-site.com/auth.html`.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## ZITADEL configuration

- Make sure to create a native application. 
- Add the redirects:
  - mobile applications with your custom scheme (in our case `com.zitadel.zitadelflutter:/`) 
  - web redirect (in our case for local development `http://localhost:4444/auth.html`) and make sure to have enabled devMode.
- To get a `refresh_token`, check the checkbox for Refresh Token and add the `offline_access` scope.

- Copy your instance url and your `clientId` and set it in `lib/main.dart` to the `zitadelIssuer` and `zitadelClientId` variables.

## Run

Search for every instance of `com.example.zitadelflutter` in the code and replace it with your app identifier (note that having underscore `_` in the callback schema is disallowed).

This exists in the following locations:
- android/app/build.gradle
- ios/Runner/Info.plist
- macos/Runner/Info.plist
- lib/main.dart

### Web

To run this example in your browser, make sure to run it on port 4444.

```bash
flutter run -d chrome --web-port=4444 --dart-define zitadel_url=[zitadel-url] --dart-define zitadel_client_id=[zitadel-client-id]
```
