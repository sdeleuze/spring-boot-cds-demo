plugins {
	java
	id("org.springframework.boot") version "3.3.0-M3"
	id("org.springframework.boot.aot") version "3.3.0-M3" // Optional but provide additional optimizations
	id("io.spring.dependency-management") version "1.1.4"
}

group = "com.example"
version = "1.0.0-SNAPSHOT"

java {
	sourceCompatibility = JavaVersion.VERSION_21
}

repositories {
	mavenCentral()
	maven { url = uri("https://repo.spring.io/milestone") }
//	maven { url = uri("https://repo.spring.io/snapshot") }
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
}

tasks.withType<Test> {
	useJUnitPlatform()
}

tasks.bootBuildImage {
	builder.set("paketobuildpacks/builder-jammy-buildpackless-base")
	buildpacks.add("anthonydahanne/java:cds-march-27")
	environment.put("BP_JVM_VERSION","21")
	environment.put("BP_JVM_CDS_ENABLED","true")
}
