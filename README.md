# Spring AppCDS demo

This repository is intended to demonstrate how to use [Spring Framework 6.1 AppCDS support](https://docs.spring.io/spring-framework/reference/6.1-SNAPSHOT/integration/class-data-sharing.html).
See also https://github.com/sdeleuze/spring-petclinic-data-jdbc/tree/appcds for related Spring Petclinic data points.

## Pre-requisites

While it is possible to use Java 17, it is recommended to use Java 21 which provide a more advanced AppCDS support.
You should also use a Java distribution with a prebuilt CDS archive.

You can use [SDK manager](https://sdkman.io/) to install and use such Java distribution:
```bash
sdk env install
sdk env
```

Check the application starts correctly without AppCDS involved:
```bash
./gradlew bootRun
```

Check the startup time, for example on my MacBook Pro M2:
```
Started AppcdsDemoApplication in 0.575 seconds (process running for 0.696)
```

## Build and run with AppCDS
 
You can either just run the `appcds.sh` script and perform those steps manually.

Build the project.
```bash
./gradlew build
```

Unpack the Spring Boot application to a JAR structure suitable for optimal performances with AppCDS:
```bash
./unpack-executable-jar.sh -d build/unpacked build/libs/appcds-demo-0.0.1-SNAPSHOT.jar
```

This shoukd create the following JAR structure:
```
build
└── unpacked
        ├── application
        │   └── spring-appcds-demo-1.0.0-SNAPSHOT.jar
        ├── dependencies
        │   ├── ...
        │   ├── spring-context-6.1.0.jar
        │   ├── spring-context-support-6.1.0.jar
        │   ├── ...
        └── run-app.jar"
```

Perform the AppCDS training run (here with Spring AOT optimizations) in order to create an additional `build/unpacked/run-app.jsa` file:
```bash
java -Dspring.aot.enabled=true \
-Dspring.context.exit=onRefresh \
-XX:ArchiveClassesAtExit=build/unpacked/run-app.jsa\
 -jar build/unpacked/run-app.jar
```

And finally run the application with AppCDS optimizations (here with Spring AOT optimizations):
```bash
java -Dspring.aot.enabled=true \
-XX:SharedArchiveFile=build/unpacked/run-app.jsa \
-jar build/unpacked/run-app.jar
```

Check the startup time, for example on my MacBook Pro M2:
```
Started AppcdsDemoApplication in 0.289 seconds (process running for 0.384)
```

## Build and run optimized container images AppCDS

Check content of the `Dockerfile` and run the `create-container-image.sh` script, or run manually:
```bash
docker build -t sdeleuze/spring-appcds-demo .
```

Then run the `run-container.sh` script, or run manually:
```bash
docker run --rm -it -p 8080:8080 sdeleuze/spring-appcds-demo
```

You can also try to deploy the resulting container image to your Cloud or Kubernetes platform.
Make sure that the server where you deploy the application has the same CPU architecture than the one where you built the AppCDS archive.