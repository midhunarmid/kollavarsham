allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

// file_picker 11 and home_widget 0.9 leave Kotlin to AGP 9's built-in
// Kotlin, which this project turns off (android.builtInKotlin=false, for
// plugins that still apply the Kotlin Gradle Plugin). Apply that plugin to
// them, with each one's Java target, so their Kotlin sources compile.
val builtInKotlinPlugins = mapOf(
    "file_picker" to org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17,
    "home_widget" to org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8,
)
subprojects {
    val target = builtInKotlinPlugins[name] ?: return@subprojects
    pluginManager.withPlugin("com.android.library") {
        pluginManager.apply("org.jetbrains.kotlin.android")
    }
    pluginManager.withPlugin("org.jetbrains.kotlin.android") {
        extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension> {
            compilerOptions { jvmTarget.set(target) }
        }
    }
}
