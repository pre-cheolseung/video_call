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
// agora_rtc_engine 플러그인이 구버전 Android SDK(API 31)로 설정되어 있는 반면,
// 하위 의존성(androidx.fragment:1.7.1)은 최소 API 34 이상을 요구하기 때문에 발생하는 에러 해결을 위한 코드
// 반드시 evaluationDependsOn(":app") 보다 위쪽에 위치
// android/app/build.gradle.kts 파일 android 블록 안의 compileSdk를 37로 수정
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension> {
            finalizeDsl { extension ->
                // 37보다 낮게 설정된 구버전 플러그인(agora_rtc_engine 등)만 37로 상향
                if ((extension.compileSdk ?: 0) < 37) {
                    extension.compileSdk = 37
                }
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
