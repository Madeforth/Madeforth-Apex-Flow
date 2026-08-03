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
subprojects {
    fun configureProject() {
        val android = extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        if (android != null) {
            // Force compileSdk 35 on all subprojects to fix google_mlkit_commons lStar error
            val currentSdk = android.compileSdkVersion?.substringAfter("android-")?.toIntOrNull() ?: 0
            if (currentSdk < 35) {
                android.compileSdkVersion(35)
            }

            // Auto-set namespace for plugins that lack one
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val namespace = getNamespace.invoke(android) as? String
                if (namespace == null || namespace.isEmpty()) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespace.invoke(android, "dev.isar.${project.name.replace("-", "_").replace(".", "_")}")
                }
            } catch (e: Exception) {
                // Ignore projects without namespace methods
            }
        }
    }
    if (state.executed) {
        configureProject()
    } else {
        afterEvaluate {
            configureProject()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
