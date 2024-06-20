import org.springframework.boot.gradle.tasks.bundling.BootBuildImage

plugins {
	java
	id("org.springframework.boot") version "3.3.1-SNAPSHOT"
	id("org.springframework.boot.aot") version "3.3.1-SNAPSHOT" // Optional but provide additional optimizations
	id("io.spring.dependency-management") version "1.1.5"
}

group = "com.example"
version = "1.0.0-SNAPSHOT"

java {
	sourceCompatibility = JavaVersion.VERSION_21
}

repositories {
	mavenCentral()
	maven { url = uri("https://repo.spring.io/snapshot") }
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
}

tasks.named<BootBuildImage>("bootBuildImage") {
	// Enable CDS and Spring AOT
	environment.set(mapOf("BP_JVM_CDS_ENABLED" to "true", "BP_SPRING_AOT_ENABLED" to "true"))

	// For multi arch (Apple Silicon) support
	builder.set("paketobuildpacks/builder-jammy-buildpackless-tiny")
	buildpacks.set(listOf("paketobuildpacks/java"))
}

tasks.withType<Test> {
	useJUnitPlatform()
}
