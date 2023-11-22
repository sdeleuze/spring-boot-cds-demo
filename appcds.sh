#!/usr/bin/env bash
set -e

# Build the application, generate the AppCDS cache, and start it with AppCDS optimization
# Use -b to only perform the build steps
# Use -s to only start the application

PROJECT_NAME="appcds-demo"
VERSION="0.0.1-SNAPSHOT"

# Change JAVA_OPTS to "" to not use Spring AOT optimizations
JAVA_OPTS="-Dspring.aot.enabled=true"

if [[ $1 != "-s" ]]; then
  if [ ! -f build/libs/${PROJECT_NAME}-${VERSION}.jar ]; then
    ./gradlew clean build
  fi
  # Explode the Spring Boot application to a JAR structure suitable for optimal performances with AppCDS
  ./explode-boot-jar.sh -d build/libs build/libs/${PROJECT_NAME}-${VERSION}.jar
  # AppCDS training run
  java $JAVA_OPTS -Dspring.context.exit=onRefresh -XX:ArchiveClassesAtExit=build/libs/run-app.jsa -jar build/libs/run-app.jar
fi
if [[ $1 != "-b" ]]; then
  # AppCDS optimized run
  java $JAVA_OPTS -XX:SharedArchiveFile=build/libs/run-app.jsa -jar build/libs/run-app.jar
fi