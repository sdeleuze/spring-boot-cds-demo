plugins {
	java
	id("org.springframework.boot") version "3.2.0"
	id("org.springframework.boot.aot") version "3.2.0" // Optional but provide additional optimizations
	id("io.spring.dependency-management") version "1.1.4"
}

group = "com.example"
version = "1.0.0-SNAPSHOT"

java {
	sourceCompatibility = JavaVersion.VERSION_21
}

tasks.bootBuildImage {
	buildpacks.add("anthonydahanne/java:app-cds-feb-16")
	environment.put("BP_JVM_VERSION","21")
	environment.put("BP_JVM_TYPE","jdk")
	environment.put("BP_APP_CDS_ENABLED","true")
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
}

tasks.withType<Test> {
	useJUnitPlatform()
}
