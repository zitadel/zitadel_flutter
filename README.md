# zitadel_flutter

A new Flutter project.

## Deploy your own

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fzitadel%2Fzitadel_flutter)

## Getting Started

This project is a starting point for a Flutter application with ZITADEL integration.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## ZITADEL configuration

Make sure to create a native application. Add the redirects for mobile applications with your custom scheme (in our case `com.zitadel.zitadelflutter`) and your web redirect (in our case for local development `http://localhost:4444/auth.html`) and make sure to have enabled devMode.

## Run

### Android

Navigate to your `AndroidManifest.xml` and add the following activity with your scheme.

```xml
<activity
    android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
    android:exported="true">
    <intent-filter android:label="flutter_web_auth_2">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="[callback-url-scheme]" /> <!-- ex: com.example.zitadelflutter -->
    </intent-filter>
</activity>
```

then connect your device or run a simulator and run your application.

### iOS

Make sure to connect your iPhone or run the simulator, then type

```bash
flutter run -d iphone
```

### Web

To run this example in your browser, make sure to run it on port 4444.

```bash
flutter run -d chrome --web-port=4444
```
