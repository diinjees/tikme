plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tikme"
    
    // ✅ FIX 1: Hardcode compileSdk to 36
    compileSdk = 36
    
    // ✅ FIX 2: Hardcode NDK version
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // ✅ Update to 17
        targetCompatibility = JavaVersion.VERSION_17  // ✅ Update to 17
    }

    kotlinOptions {
        jvmTarget = "17"  // ✅ Update to 17
    }

    defaultConfig {
        applicationId = "com.example.tikme"
        minSdk = 23  // ✅ Set explicitly (or keep flutter.minSdkVersion)
        targetSdk = 36  // ✅ Set to 36
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}