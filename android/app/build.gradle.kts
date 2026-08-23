import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        load(FileInputStream(file))
    }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile")?.let { file(it).exists() } == true

android {
    namespace = "com.gaussdev.stayalive"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.gaussdev.stayalive"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = "dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Stay Alive Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Stay Alive")
        }
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Fallback for local `flutter run --release` without a release keystore.
                // Store uploads MUST use a real release keystore — see android/key.properties.example.
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

// home_widget 0.8.0 declares `androidx.glance:glance-appwidget:1.+`. That
// dynamic range now resolves to a 1.3.0 alpha requiring AGP 9.1.0, which breaks
// release builds on our AGP 8.11.1. Pin to the latest stable Glance instead.
// ponytail: version pin over an AGP 9 upgrade; revisit if home_widget pins glance itself.
configurations.all {
    resolutionStrategy {
        force("androidx.glance:glance-appwidget:1.1.1")
    }
}
