plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.gyanti.mpcpl.gyanti_mpcpl"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.gyanti.mpcpl.gyanti_mpcpl"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    // 🔹 Signing config for release (Kotlin DSL syntax)
    signingConfigs {
        create("release") {
            keyAlias = "upload"                     // actual alias
            keyPassword = "Ravendra@123"            // key password
            storeFile = file("R:/gyanti_mpcpl/uploadkey.jks") // keystore ka actual path
            storePassword = "Ravendra@123"          // keystore password
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false      // agar proguard use karna hai to true
            isShrinkResources = false    // optional
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}