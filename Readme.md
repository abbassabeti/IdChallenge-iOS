# **iOS SDK - ID Verification**

This SDK provides an easy-to-use interface for capturing and securely storing user photos, authenticating users via biometric mechanisms, and accessing protected content (photos). The SDK ensures that sensitive data, such as images, is encrypted and securely stored in the app's sandboxed environment.

## **Overview**

This iOS SDK is built with a modular approach, ensuring separation of concerns, testability, and security. The core functionalities of this SDK include:

1. **Photo Capture**: Capturing photos using the device's camera and encrypting them before storing them.
2. **Biometric Authentication**: Authenticating users using Face ID, Touch ID, or fallback methods.
3. **Secure Storage**: Storing encrypted photos in a private directory within the app's sandbox. The SDK uses both **CryptoKit** (for iOS 13+) and **CommonCrypto** (for iOS 12 and earlier) for encryption, ensuring compatibility across iOS versions.
4. **Access Control**: Managing access to encrypted photos by ensuring users are authenticated before retrieving data, with timed access expiration.

## **Features**

1. **Photo Capture & Storage**:

   - Photos are captured via the device’s camera using the `UIImagePickerController`.
   - Captured photos are encrypted using platform-appropriate cryptographic libraries.
   - Encrypted images are stored securely in the app's private directory to ensure they remain inaccessible to other apps or users.

2. **Biometric Authentication**:

   - The SDK uses the `LocalAuthentication` framework to authenticate users using biometric features such as Face ID or Touch ID.
   - The authentication ensures that only authorized users can access sensitive content (encrypted photos).

3. **Encryption (Platform-Specific)**:

   - On **iOS 13 and later**, the SDK uses **CryptoKit** to encrypt images.
   - On **iOS 12 and earlier**, the SDK uses **CommonCrypto** for encryption.
   - This dual-approach ensures both backward compatibility and the use of the latest cryptographic standards when available.

4. **Timed Access**:

   - After successful authentication, the user is granted access to view encrypted photos for a limited time (e.g., 60 seconds).
   - A timer automatically revokes access after the timeout, requiring re-authentication.

## **Architecture**

- **Modularity**: The SDK is designed in a modular fashion with clear separation between services (e.g., photo capturing, storage, authentication), ensuring flexibility, easy testing, and maintainability.
- **Dependency Injection**: Dependencies such as storage and authentication services are injected to ensure easy mocking and testing.

### **Core Classes:**

1. **`IdVerification`**: The main class that interacts with the app to handle photo capturing, user authentication, and access control. It also manages the lifecycle of user access and revokes access after a set timeout.
2. **`PhotoCaptureManager`**: Responsible for handling photo capture using either the camera or the photo picker, depending on iOS version and capabilities.
3. **`StorageService`**: Provides methods to store, retrieve, and delete encrypted images. Handles encryption based on platform using `CryptoKit` or `CommonCrypto`.
4. **`AuthenticationManager`**: Uses the `LocalAuthentication` framework to handle biometric authentication.

## **Encryption - Platform Specific**

The SDK uses two different cryptographic libraries based on the iOS version:

### **For iOS 13+ (CryptoKit)**

The SDK uses **CryptoKit**, Apple’s modern cryptography framework introduced in iOS 13. It provides high-level APIs for secure encryption and decryption, leveraging hardware security where available.

### **For iOS 12 and Earlier (CommonCrypto)**

For older devices running iOS 12 or earlier, the SDK falls back to using **CommonCrypto**. CommonCrypto provides lower-level cryptographic functions that allow us to perform encryption and decryption.

The SDK automatically switches between **CryptoKit** and **CommonCrypto** based on the iOS version, ensuring compatibility and security.

## **Error Handling**

For reflecting accurate errors, the type IDError is exposed from the SDK. This provides a typed error, demonstrating the most common errors which might happen during usage of the library. Please feel free to use description property provided for this type, or if you require Localization, please feel free to write a mapper for it for being mapped to the keys which are defined in your own localization system.

## **Installation**

1. **Manual Integration**:

   - Clone the repository and add the relevant source files to your project.

2. **Swift Package Manager** (Future):
   - The SDK will be available via Swift Package Manager for easy integration. (Upcoming)

## **Permissions Required**

To capture photos, the following permission must be added to your app’s `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to the camera to capture your ID photos.</string>
```

## **Example Usage**

```swift
import UIKit
import IdVerificationSDK

let idVerification = IdVerification()

// Take a photo
idVerification.takePhoto(self) { result in
    switch result {
    case .success:
        print("Photo captured and stored successfully.")
    case .failure(let error):
        print("Failed to capture photo: \(error.localizedDescription)")
    }
}

// Authenticate user
idVerification.authenticateUser { result in
    switch result {
    case .success:
        print("User authenticated successfully.")
    case .failure(let error):
        print("Authentication failed: \(error.localizedDescription)")
    }
}

// Access stored photos
idVerification.accessPhotos { result in
    switch result {
    case .success(let photos):
        print("Accessed \(photos.count) photos.")
    case .failure(let error):
        print("Failed to access photos: \(error.localizedDescription)")
    }
}
```
## **Release process**

For releasing the xcframework, I created a script (build_xcframework.sh) in the root folder. This creates the proper build for both iOS Devices and Simulators, and then creates the xcframework out of that. For checking that everything works fine, I tried importing this in another iOS project and it works fine.

I also wanted to add some yaml file to make the release process automated. I created an initial sample yaml file to go that way. But considering that I need to upload the build in the repository and the amount of time needed for checking if this works fine on Github Runner, I think it's something for the future. I think the idea of having the release process automated to have the sdk published (at least to our staging for being tested automatically using some UI Test) is pretty cool for our regression. For reference you can find the xcframework output [here](https://github.com/abbassabeti/IdChallenge-iOS/tree/framework_build/XCFramework/IdFramework.xcframework) in the repository.
