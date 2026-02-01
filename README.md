# DataspikeMobile SDK

This repository contains the **iOS, Android, Flutter implementation** of **DataspikeMobile SDK**
based on an embedded **Flutter module**.

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

```bash
pod install --repo-update
```

#### Required Build Settings (Mandatory)

The following permissions **must be enabled** in your `Podfile` build settings.
Without these flags, the verification flow will not work correctly.

```ruby
'PERMISSION_CAMERA=1',
'PERMISSION_PHOTOS=1',
'PERMISSION_MEDIA_LIBRARY=1',
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
See the [example settings.gradle](https://github.com/dataspike-io/MobileSDK-Flutter-iOS/blob/master/Podfile) or check the [Updating settings.gradle](https://docs.flutter.dev/add-to-app/android/project-setup#updating-settings-gradle).

### Step 3 — Update build.gradle
See the [example build.gradle](https://github.com/dataspike-io/MobileSDK-Flutter-iOS/blob/master/Podfile) or check the [Updating build.gradle](https://docs.flutter.dev/add-to-app/android/project-setup#updating-appbuild-gradle).

## Implement in the iOS Project (Example)

### Step 1 - Implement in Code

You can check [our example](https://github.com/dataspike-io/MobileSDK-Flutter-iOS/blob/master/flutteriosexample/SomeViewController.swift) or use the official Flutter guides: [Create a single Flutter Screen](https://docs.flutter.dev/add-to-app/android/add-flutter-screen#add-a-normal-flutter-screen) & [Create a Flutter Fragment](https://docs.flutter.dev/add-to-app/android/add-flutter-fragment#add-a-flutterfragment-to-an-activity-with-a-new-flutterengine).

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
    "dsApiToken" to "your_api_token",
    "shortId" to "your_shoty_id",
    "isDebug" to true
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















