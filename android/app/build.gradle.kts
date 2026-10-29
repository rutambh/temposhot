plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rutambh.temposhot"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.rutambh.temposhot"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        resValues = true
    }

    flavorDimensions += listOf("tier")

    productFlavors {
        create("lite") {
            dimension = "tier"
            applicationId = "com.rutambh.temposhot"
            resValue("string", "app_name", "TempoShot")
        }
        create("pro") {
            dimension = "tier"
            applicationId = "com.rutambh.temposhot.pro"
            resValue("string", "app_name", "TempoShot Pro")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
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
