plugins {
    // Android Gradle plugin

    id("com.android.application") version "8.1.2" apply false
    id("com.android.library") version "8.1.2" apply false

    // Google Services Gradle plugin (correct modern version)
    id("com.google.gms.google-services") version "4.4.1" apply false

    // Kotlin
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix build directory
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
