# Spring Boot CDS demo

This repository is intended to demonstrate how to use [Spring Boot 3.3+ CDS support](https://docs.spring.io/spring-boot/3.3-SNAPSHOT/how-to/class-data-sharing.html). See also https://github.com/sdeleuze/petclinic-efficient-container.
 
## Pre-requisites

Docker is required to use Buildpacks which allows to build easily container images with CDS and Spring AOT enabled
via the `BP_JVM_CDS_ENABLED` and `BP_SPRING_AOT_ENABLED` that are enabled in the build (`build.gradle.kts`
for Gradle and `pom.xml` for Maven).

Check the application starts correctly without CDS involved:
```bash
./gradlew bootRun
```

Check the startup time, for example on my MacBook Pro M2:
```
Started CdsDemoApplication in 0.575 seconds (process running for 0.696)
```

## Build and run with CDS

Build the container image with Gradle.
```bash
./gradlew bootBuildImage
```

or with Maven
```bash
./mvnw spring-boot:build-image
```

Then run it with Docker:
```bash
docker run --rm -p 8080:8080 spring-cds-demo:1.0.0-SNAPSHOT
```

Check the startup time which should now be significantly lower:
```bash
Started CdsDemoApplication in 0.294 seconds (process running for 0.371)
```