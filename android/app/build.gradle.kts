plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter doit venir après Android et Kotlin
    id("dev.flutter.flutter-gradle-plugin")
    // Si tu ajoutes Firebase (google-services.json) plus tard :
    // id("com.google.gms.google-services")
}

android {
    namespace = "com.example.veh_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.veh_app"
        // flutter.minSdkVersion est normalement 21 ; on s'assure de ne pas descendre en-dessous
        minSdk = maxOf(21, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // *** Java 17 + desugaring requis ***
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // signature debug par défaut pour pouvoir lancer en --release
            signingConfig = signingConfigs.getByName("debug")
            // Si besoin plus tard :
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Obligatoire quand on active coreLibraryDesugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
