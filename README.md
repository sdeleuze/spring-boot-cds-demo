# Spring CDS demo

This repository is intended to demonstrate how to use [Spring Framework 6.1 CDS support](https://docs.spring.io/spring-framework/reference/integration/class-data-sharing.html).

See also:
 - https://github.com/sdeleuze/spring-petclinic-data-jdbc/tree/cds for related Spring Petclinic data points
 - https://github.com/snicoll/cds-log-parser which allows to produce a report about class loading
 - [spring-boot#38276](https://github.com/spring-projects/spring-boot/issues/38276) Improve exploded structure experience for efficient deployments
 - [spring-boot#34115](https://github.com/spring-projects/spring-boot/issues/34115) Investigate automatic CDS support

## Pre-requisites

While it is possible to use Java 17, it is recommended to use Java 21 which provide a more advanced CDS support.
You should also use a Java distribution with a prebuilt CDS archive.

You can use [SDK manager](https://sdkman.io/) to install and use such Java distribution:
```bash
sdk env install
sdk env
```

Check the application starts correctly without CDS involved:
```bash
./gradlew bootRun
```

Check the startup time, for example on my MacBook Pro M2:
```
Started CdsDemoApplication in 0.575 seconds (process running for 0.696)
```

## Build and run with CDS
 
You can either just run the `cds.sh` script and perform those steps manually.

Build the project.
```bash
./gradlew build
```

Unpack the Spring Boot application to a JAR structure suitable for optimal performances with CDS:
```bash
./unpack-executable-jar.sh -d build/unpacked build/libs/cds-demo-0.0.1-SNAPSHOT.jar
```

This should create the following JAR structure:
```
build
└── unpacked
        ├── application
        │   └── spring-cds-demo-1.0.0-SNAPSHOT.jar
        ├── dependencies
        │   ├── ...
        │   ├── spring-context-6.1.0.jar
        │   ├── spring-context-support-6.1.0.jar
        │   ├── ...
        └── run-app.jar"
```

Perform the CDS training run (here with Spring AOT optimizations) in order to create an additional `build/unpacked/application.jsa` file:
```bash
java -Dspring.aot.enabled=true \
-Dspring.context.exit=onRefresh \
-XX:ArchiveClassesAtExit=build/unpacked/application.jsa \
-jar build/unpacked/run-app.jar
```

And finally run the application with CDS optimizations (here with Spring AOT optimizations):
```bash
java -Dspring.aot.enabled=true \
-XX:SharedArchiveFile=build/unpacked/application.jsa \
-jar build/unpacked/run-app.jar
```

Check the startup time, for example on my MacBook Pro M2:
```
Started CdsDemoApplication in 0.289 seconds (process running for 0.384)
```

## Build and run optimized container images CDS

You can use the Paketo Buildpacks to create a container image leveraging app cds optimization.

Since it's an early release, it's not part of the official `paketobuildpacks/java` yet which is referenced by default by the boot plugin.

Instead, you need for now to reference this Java composite buildpack: `anthonydahanne/java:app-cds`

Also, a few environment variables need to be set; all in all, check the `build.gradle.kts` file and pay attention to:

```kotlin
tasks.bootBuildImage {
	buildpacks.add("anthonydahanne/java:app-cds-feb-16")
	environment.put("BP_JVM_VERSION","21")
    environment.put("BP_JVM_TYPE","jdk")
    environment.put("BP_APP_CDS_ENABLED","true")
}
```

```bash
 ./gradlew bootBuildImage
```

Then run the `run-container.sh` script, or run manually:
```bash
docker run --rm -it -p 8080:8080 spring-cds-demo:1.0.0-SNAPSHOT
```

You can also try to deploy the resulting container image to your Cloud or Kubernetes platform.
Make sure that the server where you deploy the application has the same CPU architecture than the one where you built the CDS archive.
