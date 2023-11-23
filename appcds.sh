#!/usr/bin/env bash
set -e

# Build the application, generate the AppCDS cache, and start it with AppCDS optimization
# Use -b to only perform the build steps
# Use -s to only start the application

PROJECT_NAME="spring-appcds-demo"
VERSION="1.0.0-SNAPSHOT"

# Change JAVA_OPTS to "" to not use Spring AOT optimizations
JAVA_OPTS="-Dspring.aot.enabled=true"

if [[ $1 != "-s" ]]; then
  if [ ! -f build/libs/${PROJECT_NAME}-${VERSION}.jar ]; then
    ./gradlew build
  fi

  # Unpack the Spring Boot executable JAR in a way suitable for optimal performances with AppCDS
  ./unpack-executable-jar.sh -d build/unpacked build/libs/${PROJECT_NAME}-${VERSION}.jar

  # AppCDS training run
  java $JAVA_OPTS -Dspring.context.exit=onRefresh -XX:ArchiveClassesAtExit=build/unpacked/run-app.jsa -jar build/unpacked/run-app.jar
fi

if [[ $1 != "-b" ]]; then
  # AppCDS optimized run
  java $JAVA_OPTS -XX:SharedArchiveFile=build/unpacked/run-app.jsa -jar build/unpacked/run-app.jar
fi
