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

// Fallback namespace untuk modul dependensi yang belum mendefinisikan `android.namespace`
// Mengatasi error: "Namespace not specified" pada plugin lama (mis. pedometer)
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            // Coba konfigurasi LibraryExtension jika tersedia
            val libExt = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (libExt != null) {
                if (libExt.namespace.isNullOrEmpty()) {
                    libExt.namespace = project.group.toString()
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
