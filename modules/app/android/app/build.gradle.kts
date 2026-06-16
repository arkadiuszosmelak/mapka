import java.util.Properties

plugins {
    id("com.android.application")
    // Firebase (Google services) — must be applied before the Flutter plugin.
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is driven by android/key.properties (not committed). In CI the
// file is recreated from GitHub Secrets. When absent, release falls back to the
// debug keys so local/PR builds still work without the keystore.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.croxoner.mapka"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        // Required for the per-flavor resValue("string", "app_name", ...) below
        // (disabled by default in AGP 8+).
        resValues = true
    }

    defaultConfig {
        applicationId = "com.croxoner.mapka"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    flavorDimensions += "flavor"
    productFlavors {
        create("dev") {
            dimension = "flavor"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Mapka Dev")
        }
        create("staging") {
            dimension = "flavor"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Mapka Staging")
        }
        create("prod") {
            dimension = "flavor"
            resValue("string", "app_name", "Mapka")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
