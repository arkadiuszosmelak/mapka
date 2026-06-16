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
// mapbox_maps_flutter pins compileSdk 35 but (via flutter_plugin_android_lifecycle)
// must compile against 36 — force 36 on every Android module. Declared before the
// evaluationDependsOn block so :app isn't already evaluated when this registers.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { android ->
            if (android is com.android.build.gradle.BaseExtension) {
                android.compileSdkVersion(36)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
