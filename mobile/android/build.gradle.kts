// FILE: android/build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // PERBAIKAN UTAMA DISINI:
        // Menggunakan versi 8.1.0 agar kompatibel dengan Gradle Wrapper 8.3
        // Perhatikan penggunaan tanda kurung ("...") karena ini file .kts
        classpath("com.android.tools.build:gradle:8.7.0")

        // Pastikan Kotlin plugin juga ada (versi 1.9.0 cukup stabil untuk Flutter saat ini)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        classpath("com.google.gms:google-services:4.4.2")
    }
}   

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// --- Kode Bawaan Project Kamu (Tidak perlu diubah) ---

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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