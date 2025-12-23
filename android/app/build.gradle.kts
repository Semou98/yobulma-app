plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.yoboulma_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" //flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

defaultConfig {
    applicationId = "com.example.yoboulma_app"
    
    // Remplacez flutter.minSdkVersion par 21
    minSdk = flutter.minSdkVersion 
    
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    // Force une version compatible avec Gradle 8.7.3
    constraints {
        implementation("androidx.activity:activity:1.9.3") {
            because("Version 1.11.0 requires AGP 8.9.1")
        }
        implementation("androidx.activity:activity-ktx:1.9.3") {
            because("Version 1.11.0 requires AGP 8.9.1")
        }
    }
}