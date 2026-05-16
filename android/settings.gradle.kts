pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.android.application") version "8.1.4" apply false
    id("com.android.library") version "8.1.4" apply false
}

include(":app")

val localPropertiesFile = rootDir.resolve("local.properties")
val localProperties = java.util.Properties().apply {
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use(::load)
    }
}

val flutterRoot = localProperties.getProperty("flutter.sdk") ?: throw GradleException(
    "Flutter SDK not found. Define location with flutter.sdk in the local.properties file."
)

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
