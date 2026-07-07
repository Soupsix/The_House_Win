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
    val configureProject = {
        if (extensions.findByName("android") != null) {
            val android = extensions.getByName("android")
            try {
                val namespaceMethod = android.javaClass.getMethod("getNamespace")
                val setNamespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                if (namespaceMethod.invoke(android) == null) {
                    // Try to generate a namespace based on project name
                    val cleanName = project.name.replace("[^a-zA-Z0-9]".toRegex(), "").lowercase()
                    val fallbackNamespace = "com.example.$cleanName"
                    setNamespaceMethod.invoke(android, fallbackNamespace)
                    logger.quiet("Injected namespace $fallbackNamespace for subproject ${project.name}")
                }
            } catch (e: Exception) {
                // Ignore if methods don't exist
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

    // Force Java compilation compatibility to 17
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    // Force Kotlin compilation compatibility to 17
    tasks.configureEach {
        if (name.startsWith("compile") && name.contains("Kotlin")) {
            try {
                val compilerOptions = javaClass.getMethod("getCompilerOptions").invoke(this)
                val jvmTargetProperty = compilerOptions.javaClass.getMethod("getJvmTarget")
                val jvmTarget = jvmTargetProperty.invoke(compilerOptions)
                val setMethod = jvmTarget.javaClass.getMethod("set", Object::class.java)
                val jvmTargetEnumClass = Class.forName("org.jetbrains.kotlin.gradle.dsl.JvmTarget")
                val jvm17Value = jvmTargetEnumClass.getField("JVM_17").get(null)
                setMethod.invoke(jvmTarget, jvm17Value)
            } catch (e: Exception) {
                try {
                    val kotlinOptions = javaClass.getMethod("getKotlinOptions").invoke(this)
                    val setJvmTarget = kotlinOptions.javaClass.getMethod("setJvmTarget", String::class.java)
                    setJvmTarget.invoke(kotlinOptions, "17")
                } catch (e2: Exception) {
                    // Ignore
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

