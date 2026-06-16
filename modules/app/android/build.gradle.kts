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

// mapbox_maps_flutter (via flutter_plugin_android_lifecycle) requires compileSdk
// 36, which the plugin modules don't pick up from the app — force it on every
// Android module. Flutter's default is still 35.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { android ->
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
