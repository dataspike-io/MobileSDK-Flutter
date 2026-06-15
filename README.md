# DataspikeMobile SDK

This repository contains the **iOS, Android, Flutter implementation** of **DataspikeMobile SDK**
based on an embedded **Flutter module**.

Supported platforms:

* **Android:** minSdk 21+
* **iOS:** 16 or later

--- 

## Documentation

iOS integration guide: [iOS Integration Instructions](https://github.com/dataspike-io/MobileSDK-Flutter#implementation-guide-ios)
- Example project: [Sample iOS Project Repository](https://github.com/dataspike-io/MobileSDK-Flutter-iOS)


Android integration guide: [Android Integration Instructions](https://github.com/dataspike-io/MobileSDK-Flutter#implementation-guide-android)
- Example project: [Sample Android Project Repository](https://github.com/dataspike-io/MobileSDK-Flutter-Android)


Flutter integration guide: [Flutter Integration Instructions](https://github.com/dataspike-io/MobileSDK-Flutter#implementation-guide-flutter)
- Example project: [Sample Flutter Project Repository](https://github.com/dataspike-io/MobileSDK-Flutter-App)

---

## Install Flutter

Install Flutter on your computer using the official documentation:

https://docs.flutter.dev/install

For Android implementation there is another way (follow the instructions):

https://docs.flutter.dev/add-to-app/android/project-setup#depend-on-the-android-archive-aar

---

## Implementation Guide (iOS)

Follow these steps to integrate DataspikeMobile SDK into your iOS project.

### Step 1 — Add Flutter Module (Git submodule)

From your iOS project root:

```bash
mkdir -p DataspikeModule
git submodule add -b main https://github.com/dataspike-io/MobileSDK-Flutter.git DataspikeModule/dataspike_module
git submodule update --init --recursive
cd DataspikeModule/dataspike_module/dataspike_module
flutter pub get
cd -
```

### Step 2 — Install Podfile
See the [example Podfile](https://github.com/dataspike-io/MobileSDK-Flutter-iOS/blob/master/Podfile) or check the [Update your Podfile guide](https://docs.flutter.dev/add-to-app/ios/project-setup#update-your-podfile). 
We strongly recommend reviewing the [limitations](https://github.com/dataspike-io/MobileSDK-Flutter/edit/main/README.md#current-limitations) described above and configuring a separate iOS target (with its own scheme and Pod configuration) dedicated to verification, in order to safely test the SDK in Release mode on real devices without affecting simulator builds or the main application target.

```bash
pod install --repo-update
```

#### Required Build Settings (Mandatory)

The following permissions **must be enabled** in your `Podfile` build settings.
Without these flags, the verification flow will not work correctly.

```ruby
'PERMISSION_CAMERA=1',
'PERMISSION_PHOTOS=1',
```

### Step 3 — Update submodule
```bash
git submodule update --init --recursive
```

### Step 4 — Commit Flutter Module (optional)
```bash
cd DataspikeModule/dataspike_module
git fetch
git checkout <commit_or_tag>
cd -
git add DataspikeModule/dataspike_module
git commit -m "Update DataspikeModule"
```

## Implement in the iOS Project (Example)

### Step 1 - Disable User Script Sandboxing

Open **Xcode → Target → Build Settings** and set:

- **User Script Sandboxing** = **NO**

### Step 2 - Add Permissions (Camera + Local Network)

Add the following keys to your `Info.plist` (ensure they are present for the configuration you run — e.g. both Debug and Release plists if you use separate files):

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSMotionUsageDescription`
- `NSLocalNetworkUsageDescription` (Debug only)

- `NSBonjourServices` (Debug only): `_dartVmService._tcp`, `_googlecast._tcp`

### Step 3 - Implement in Code

You can check [our example](https://github.com/dataspike-io/MobileSDK-Flutter-iOS/blob/master/flutteriosexample/SomeViewController.swift) or use the official Flutter guides: [Create a FlutterEngine](https://docs.flutter.dev/add-to-app/ios/add-flutter-screen#create-a-flutterengine).

### Step 4 — Setup API

1) **Get your API token**

Create an account and get your API token here:  
https://dash.dataspike.io/api/settings

2) **Create a new verification and obtain `verification_url_id`**

Send a request to create a verification according to the API documentation:  
https://docs.dataspike.io/api-reference/verifications/create-new-verification

The response will contain `verification_url_id`.

3) **Use `verification_url_id` in DataspikeMobile SDK**

Pass the received `verification_url_id` with API token to our API / SDK as required by your integration.

### Step 5 — Open Verification Flow (Example)

Below is an example of how to start the Dataspike verification flow from the iOS host app.

- To **open the flow**, use your **API token** and **shortId**
- To **receive the result**, handle the `onVerificationCompleted` callback

### Example (Swift)

```swift
channel.setMethodCallHandler { call, result in
  if call.method == "onVerificationCompleted" {
    if let args = call.arguments as? [String: String] {
      if args["status"] == "Completed" {
        flutterVC.dismiss(animated: true, completion: nil)
      }
    }
    result(nil)
  } else {
    result(FlutterMethodNotImplemented)
  }
}

present(flutterVC, animated: true) {
  channel.invokeMethod("startDataspikeFlow", arguments: [
    "dsApiToken": "your_token",
    "shortId": "your_short_id",
    "isDebug": true // set to false for production
  ])
}
```

### Verification Statuses
The onVerificationCompleted callback can return the following statuses: "Completed", "Expired", "Failed"

## Known Issues & Troubleshooting

### LLDB initialization issues

In some cases, Flutter debugging may not work correctly due to missing LLDB configuration.

Follow the official Flutter guide to set up the LLDB init file:
https://docs.flutter.dev/add-to-app/ios/project-setup#set-lldb-init-file

This step is required to properly attach the debugger when running Flutter inside a native iOS app.

In some cases, you may also need to explicitly set the iOS platform version
in the Flutter module podspec:
```ruby
s.platform = :ios, '16.0' // Minimum version iOS 16.0
```

---

### Local Network permission issues

Flutter tools may require access to the local network (for example, for the Dart VM Service).

If you encounter issues related to local network permissions, follow the official documentation:
https://docs.flutter.dev/add-to-app/ios/project-setup#set-local-network-privacy-permissions

Make sure the required Local Network permissions are added to your `Info.plist`
and allowed in iOS system settings.

---

### Apple Silicon build issues

On Apple Silicon Macs, you may encounter build issues related to simulator architectures.

To mitigate known issues, follow the official Flutter guide:
https://docs.flutter.dev/add-to-app/ios/project-setup#mitigate-known-issue-with-apple-silicon-macs

This typically involves excluding the `arm64` architecture for iOS simulators
or adjusting CocoaPods build settings.

## Current Limitations

- **Device-only verification**  
  At the moment, verification is fully supported **only on real devices**.  
  Verification on iOS simulators may not work.  
  We are aware of this limitation and plan to improve simulator support in future releases.

- **Slow image loading in Debug builds**  
  In **Debug** configuration, image loading during the verification flow may take significantly longer than expected.  
  For a smoother and more accurate verification experience, we recommend testing the flow using the **Release** build configuration.

- **Target & Pod Configuration Recommendation**  
  To prevent simulator build failures and debugging conflicts, the verification SDK should be isolated at the target level.

  The recommended setup is:
  - Create a separate iOS target dedicated to verification.
  - Create a corresponding scheme for that target.
  - Add the verification Pod only to this new target.
  - Do not include the main application target inside the verification Pod block.
  
    Example:
    ```bash
    target 'MainApp' do
    # Regular pods only
    end

    target 'MainAppVerification' do
    pod 'DataSpikeMobileSDK'
    end
    ```

  This ensures:
  - The main Debug build (including simulator builds) remains stable.
  - Device-only dependencies are not linked into unsupported configurations.
  - CI pipelines and local development builds are not affected.
    
  Release Mode Testing Requirement:
  - Verification should always be tested on a real device using the Release build configuration of the dedicated verification target.
    
  This guarantees:
  - Accurate image processing performance
  - Proper camera and ML execution timing
  - Behavior consistent with production environments
  - Testing verification in Debug mode or on simulators may lead to misleading performance characteristics and unreliable results.

---

## Implementation Guide (Android)

Follow these steps to integrate DataspikeMobile SDK into your Android project.

### Step 1 — Add Flutter Module (Git submodule)

From your Android project root:

```bash
mkdir -p DataspikeModule
git submodule add -b main https://github.com/dataspike-io/MobileSDK-Flutter.git DataspikeModule/dataspike_module
git submodule update --init --recursive
cd DataspikeModule/dataspike_module/dataspike_module
flutter pub get
cd -
```

### Step 2 — Install settings.gradle
See the [example settings.gradle](https://github.com/dataspike-io/MobileSDK-Flutter-Android/blob/master/settings.gradle.kts) or check the [Updating settings.gradle](https://docs.flutter.dev/add-to-app/android/project-setup#updating-settings-gradle).

For this implementation, the `settings.gradle.kts` file **must** be configured as shown below to properly include the Flutter module into the existing Android project:

```kotlin
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "ImplementationFlutterExample"
include(":app")
val filePath = settingsDir.toString() + "/DataspikeModule/dataspike_module/dataspike_module/.android/include_flutter.groovy"
apply(from = File(filePath))
```

### Step 3 — Update build.gradle
See the [example build.gradle](https://github.com/dataspike-io/MobileSDK-Flutter-Android/blob/master/app/build.gradle.kts) or check the [Updating build.gradle](https://docs.flutter.dev/add-to-app/android/project-setup#updating-appbuild-gradle).

## Implement in the Android Project (Example)

### Step 1 - Implement in Code

You can check [our example](https://github.com/dataspike-io/MobileSDK-Flutter-Android/blob/master/app/src/main/java/com/example/implementationflutterexample/MainActivity.kt) or use the official Flutter guides: [Create a single Flutter Screen](https://docs.flutter.dev/add-to-app/android/add-flutter-screen#add-a-normal-flutter-screen) & [Create a Flutter Fragment](https://docs.flutter.dev/add-to-app/android/add-flutter-fragment#add-a-flutterfragment-to-an-activity-with-a-new-flutterengine).

### Step 2 — Setup API

1) **Get your API token**

Create an account and get your API token here:  
https://dash.dataspike.io/api/settings

2) **Create a new verification and obtain `verification_url_id`**

Send a request to create a verification according to the API documentation:  
https://docs.dataspike.io/api-reference/verifications/create-new-verification

The response will contain `verification_url_id`.

3) **Use `verification_url_id` in DataspikeMobile SDK**

Pass the received `verification_url_id` with API token to our API / SDK as required by your integration.

### Step 3 — Open Verification Flow (Example)

Below is an example of how to start the Dataspike verification flow from the iOS host app.

- To **open the flow**, use your **API token** and **shortId**
- To **receive the result**, handle the `onVerificationCompleted` callback

### Android permissions

```kotlin
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
```

### Example (Kotlin)

```swift
channel.setMethodCallHandler { call, result ->
  if (call.method == "onVerificationCompleted") {
    val args = call.arguments as? Map<*, *>
    val status = args?.get("status")
    if (status == "Completed") {
      // Your Actions
    }
    result.success(null)
  } else {
    result.notImplemented()
  }
}

channel.invokeMethod(
  "startDataspikeFlow",
  mapOf(
    "dsApiToken": "your_token",
    "shortId": "your_short_id",
    "isDebug" // set to false for production
  )
)
```

### Verification Statuses
The onVerificationCompleted callback can return the following statuses: "Completed", "Expired", "Failed"

### Android ABI Warning

If the existing Android app supports additional CPU architectures (e.g. `mips`, `x86`), integration issues may occur.

Flutter supports AOT builds only for:
- `armeabi-v7a`
- `arm64-v8a`
- `x86_64`

Please ensure that the Android project uses only supported ABIs and follow the official Flutter documentation:  
https://docs.flutter.dev/deployment/android#android-app-bundles-and-apk-splitting

---

## Implementation Guide (Flutter)

Follow these steps to integrate DataspikeMobile SDK into your Flutter project.

### Step 1 — Add Flutter Module (Git dependency)

From your Android project root:

```bash
dependencies:
  flutter:
    sdk: flutter
  
dataspikemobilesdk:
  git:
    url: https://github.com/dataspike-io/MobileSDK-Flutter
    ref: 1.0.0
```

### Step 2 — Start DataSpike flow from Flutter

The DataSpike verification flow is started directly from Flutter using the SDK API.

```dart
import 'package:dataspikemobilesdk/dataspikemobilesdk.dart';

final _dataspikemobilesdkPlugin = Dataspikemobilesdk();

_dataspikemobilesdkPlugin.startDataspikeFlow(
  context: context,
  dependencies: .new(
    isDebug: true, // set to false for production
    dsApiToken: "your_token",
    shortId: "your_short_id",
  ),
  callback: (status) {},
);
```

You can use:
[Our example inside the current repository to see more detailed implementation](https://github.com/dataspike-io/MobileSDK-Flutter/blob/main/example/lib/main.dart) or use [our example in separate project](https://github.com/dataspike-io/MobileSDK-Flutter-App) 

### Permissions (IOS)

Add the following keys to your `Info.plist` (ensure they are present for the configuration you run — e.g. both Debug and Release plists if you use separate files):

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSMotionUsageDescription`
- `NSLocalNetworkUsageDescription` (Debug only)

The following permissions **must be enabled** in your `Podfile` build settings. [Look example](https://github.com/dataspike-io/MobileSDK-Flutter/blob/main/example/ios/Podfile) 
Without these flags, the verification flow will not work correctly.

```ruby
'PERMISSION_CAMERA=1',
'PERMISSION_PHOTOS=1',
```

### Permissions (ANDROID)

```kotlin
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
```

### Verification Statuses
The onVerificationCompleted callback can return the following statuses: Completed, Expired, Failed

### Limitations iOS 
Due to certain iOS platform [limitations](https://github.com/dataspike-io/MobileSDK-Flutter#apple-silicon-build-issues), Flutter-based integration may require running Xcode and related tooling under Rosetta on Apple Silicon machines for proper testing and dependency compatibility.

---

## Implementation Guide (React Native - iOS)

Follow these steps to integrate DataspikeMobile SDK into your React Native project.

### Step 1 — Add Flutter Module (Git dependency)
There is an option to add it once for all project or separately for iOS and Android.

```bash
mkdir -p DataspikeModule
git submodule add -b main https://github.com/dataspike-io/MobileSDK-Flutter.git DataspikeModule/dataspike_module
git submodule update --init --recursive
cd DataspikeModule/dataspike_module/dataspike_module
flutter pub get
cd -
```

### Step 2 — Update and install your podfile

[Example of a podfile](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/ios/Podfile)

In your iOS project part:
```bash
pod install --repo-update
```

### Step 3 - Add bridge files to your .xcworkspace in Xcode

1. [DataspikeModule.m](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/ios/DataspikeExample/DataspikeModule.m)
2. [DataspikeModule.swift](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/ios/DataspikeModule.swift)


### Step 4 - Permissions (IOS)

Add the following keys to your `Info.plist` (ensure they are present for the configuration you run — e.g. both Debug and Release plists if you use separate files):

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSMotionUsageDescription`
- `NSLocalNetworkUsageDescription` (Debug only)

The following permissions **must be enabled** in your `Podfile` build settings. [Look example](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/ios/Podfile)
Without these flags, the verification flow will not work correctly.

```ruby
'PERMISSION_CAMERA=1',
'PERMISSION_PHOTOS=1',
```

### Step 5 - Update App.tsx

Update App.tsx according to [example](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/App.tsx) or your current implementation, where the first argument is "dsApiToken" and the second one is "shortId".

### Step 6 - Run iOS to check

```ruby
npx react-native run-ios
```

## Implementation Guide (React Native - Android)

### Step 1 — Add Flutter Module (Git dependency)
There is an option to add it once for all project or separately for iOS and Android.

```bash
mkdir -p DataspikeModule
git submodule add -b main https://github.com/dataspike-io/MobileSDK-Flutter.git DataspikeModule/dataspike_module
git submodule update --init --recursive
cd DataspikeModule/dataspike_module/dataspike_module
flutter pub get
cd -
```

### Step 2 - Build the module as an AAR

**Requirement: the module's `compileSdk` must be ≥ 36.** Otherwise `checkAarMetadata` fails — `file_picker` and `flutter_plugin_android_lifecycle` require compiling against API 36.

In `dataspikemobilesdk/android/build.gradle`:

```groovy
android {
    compileSdk = 36
}
```

If it contains plugins on an old Kotlin Gradle Plugin (e.g. `tflite_flutter`) and the build fails on a JVM-target mismatch (Java 11 vs Kotlin 21), add to the module's `gradle.properties`:

```properties
kotlin.jvm.target.validation.mode=warning
```

Build the AAR:

```bash
cd android/DataspikeModule/dataspike_module/<module>
flutter build aar
```

From the output, note the local repo path (`build/host/outputs/repo`) and the dependency coordinates (`com.example.dataspike_module:flutter_debug:1.0`, etc.).

### Step 3 - Wire the AAR into the host

#### 3.1 `android/settings.gradle`

There must be no source integration. If it's still there — **remove it**:

```groovy
// REMOVE if present:
setBinding(new Binding([gradle: this]))
evaluate(new File(settingsDir, '.../.android/include_flutter.groovy'))
```

#### 3.2 `android/build.gradle.kts` (root) — Kotlin version

The host's Kotlin must **match** the version the AAR was built with (Flutter 3.4x → Kotlin 2.3.20). An older compiler can't read newer metadata (compatibility is forward-only).

```kotlin
buildscript {
    extra["kotlinVersion"] = "2.3.20"
    // ...
    dependencies {
        classpath("com.android.tools.build:gradle")
        classpath("com.facebook.react:react-native-gradle-plugin")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.3.20")
    }
}
```

#### 3.3 `android/app/build.gradle.kts` — repositories and dependencies

**Put the repositories at the app level, not in settings.** With `repositoriesMode = PREFER_PROJECT`, `:app` has its own project repos (added by the react plugin), so settings-level repos are ignored for it.

```kotlin
repositories {
    google()
    mavenCentral()
    maven { url = uri("${rootProject.projectDir}/DataspikeModule/dataspike_module/dataspike_module/build/host/outputs/repo") }
    maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
}

dependencies {
    // ...
    debugImplementation("com.example.dataspike_module:flutter_debug:1.0")
    releaseImplementation("com.example.dataspike_module:flutter_release:1.0")
    // no profile: RN only has debug/release
}
```

### Step 4 - Native Bridge 

1. [DataspikeModule.kt](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/android/app/src/main/java/com/dataspikeexample/DataspikeModule.kt)
2. [DataspikePackage.kt](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/android/app/src/main/java/com/dataspikeexample/DataspikePackage.kt)
3. [Register in `MainApplication.kt`](https://github.com/dataspike-io/MobileSDK-Flutter-React/blob/master/android/app/src/main/java/com/dataspikeexample/MainApplication.kt)

### Step 5 - Permissions (ANDROID)

```kotlin
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
```

### Step 6 - FlutterActivity (inside `<application>`)

Without this, `startActivity(FlutterActivity…)` throws `ActivityNotFoundException` and the app crashes when the button is pressed.

```xml
<activity
    android:name="io.flutter.embedding.android.FlutterActivity"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize"
    android:exported="false" />
```

### Step 7 - Calling from JS 

```js
import { NativeModules } from 'react-native';

const { DataspikeModule } = NativeModules;
const status = await DataspikeModule.startFlow(apiToken, shortId);
// status comes from onVerificationCompleted
```

### Step 8 - Build and run

```bash
# 1) Metro in a separate terminal
npx react-native start

# 2) forward the port to the device
adb reverse tcp:8081 tcp:8081

# 3) build + install + launch
npx react-native run-android
```

### Step 9 - Verification Statuses
The onVerificationCompleted callback can return the following statuses: Completed, Expired, Failed


### Maintenance (Android)

- **Any change in the Flutter module (`dataspike_module` / `dataspikemobilesdk`) → rebuild the AAR with `flutter build aar`.** The host consumes the prebuilt artifact and won't pick up changes on its own.
- After rebuilding the AAR, run `./gradlew --stop && ./gradlew clean` if you hit odd compile errors (corrupted incremental cache / stale compiler in the daemon).
- Commit the submodule at the right revision so CI and other developers build the same module version.

---
