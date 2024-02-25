#!/usr/bin/env bash
set -e

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "unpack-executable-jar.sh - unpack Spring Boot executable JAR in order to run"
      echo "the application efficiently and maximizing CDS effectiveness."
      echo " "
      echo "my-unpack-dir
            ├── application
            │   └── my-app-1.0.0-SNAPSHOT.jar
            ├── dependencies
            │   ├── ...
            │   ├── spring-context-6.1.0.jar
            │   ├── spring-context-support-6.1.0.jar
            │   └── ...
            ├── ext
            │   ├── jar1.jar
            │   ├── jar2.jar
            │   └── ...
            └── run-app.jar"
      echo " "
      echo "unpack-executable-jar.sh [options] application.jar"
      echo " "
      echo "options:"
      echo "-d directory              Create the files in directory"
      echo "-a jar1.jar,jar2.jar      Comma separated list of additional jars to include"
      echo "-q                        Make some output more quiet"
      echo "-h, --help                Show brief help"
      exit 0
      ;;
    -d)
      shift
      if test $# -gt 0; then
        export DESTINATION=$1
      else
        echo "no destination specified"
        exit 1
      fi
      shift
      ;;
    -a)
      shift
      export ADDITIONAL=$(echo $1 | tr "," "\n")
      ;;
    -q)
      shift
      QUIET=true
      ;;
    *)
      export JAREXE=$1
      shift
      ;;
  esac
done

if [ -z "$JAREXE" ]; then
  echo "specifying the executable JAR is mandatory"
  exit 1
fi

UNPACK_TMPDIR="${TMPDIR}unpack-executable-jar"
if [ -d "$UNPACK_TMPDIR" ]; then rm -Rf "$UNPACK_TMPDIR"; fi

if [ -z "$DESTINATION" ]; then
  DESTINATION="$(pwd)"
fi

unzip -q "$JAREXE" -d "$UNPACK_TMPDIR"
mkdir -p "${DESTINATION}/application"
mkdir -p "${DESTINATION}/dependencies"

MANIFEST_APP="${UNPACK_TMPDIR}/MANIFEST-RUN-APP.MF"
MANIFEST_RUN_APP="${UNPACK_TMPDIR}/MANIFEST-RUN-APP.MF"

MAIN_CLASS=$(grep "Start-Class:" "${UNPACK_TMPDIR}/META-INF/MANIFEST.MF" | cut -d ' ' -f 2)
IMPLEMENTATION_VERION=$(grep "Implementation-Version:" "${UNPACK_TMPDIR}/META-INF/MANIFEST.MF" | cut -d ' ' -f 2)
IMPLEMENTATION_TITLE=$(grep "Implementation-Title:" "${UNPACK_TMPDIR}/META-INF/MANIFEST.MF" | cut -d ' ' -f 2)
SPRING_BOOT_VERSION=$(grep "Spring-Boot-Version:" "${UNPACK_TMPDIR}/META-INF/MANIFEST.MF" | cut -d ' ' -f 2)
BUILD_JDK_SPEC=$(grep "Build-Jdk-Spec:" "${UNPACK_TMPDIR}/META-INF/MANIFEST.MF" | cut -d ' ' -f 2)

echo "Manifest-Version: 1.0" > "${MANIFEST_APP}"
echo "Main-Class: ${MAIN_CLASS}" >> "${MANIFEST_APP}"
echo "Implementation-Version: ${IMPLEMENTATION_VERION}" >> "${MANIFEST_APP}"
echo "Implementation-Title: ${IMPLEMENTATION_TITLE}" >> "${MANIFEST_APP}"
echo "Spring-Boot-Version: ${SPRING_BOOT_VERSION}" >> "${MANIFEST_APP}"
echo "Build-Jdk-Spec: ${BUILD_JDK_SPEC}" >> "${MANIFEST_APP}"

if [ -f "${UNPACK_TMPDIR}/META-INF/build-info.properties" ]; then
  mv "${UNPACK_TMPDIR}/META-INF/build-info.properties" "${UNPACK_TMPDIR}/BOOT-INF/classes/META-INF/build-info.properties"
fi

if [ -f "${UNPACK_TMPDIR}/META-INF/spring.factories" ]; then
  mv "${UNPACK_TMPDIR}/META-INF/spring.factories" "${UNPACK_TMPDIR}/BOOT-INF/classes/META-INF/spring.factories"
fi

jar cfm "${DESTINATION}/application/$(basename "$JAREXE")" "${MANIFEST_APP}" -C "${UNPACK_TMPDIR}/BOOT-INF/classes/" .

echo "Manifest-Version: 1.0" > "${MANIFEST_RUN_APP}"
echo "Main-Class: ${MAIN_CLASS}" >> "${MANIFEST_RUN_APP}"
echo "Implementation-Version: ${IMPLEMENTATION_VERION}" >> "${MANIFEST_RUN_APP}"
echo "Implementation-Title: ${IMPLEMENTATION_TITLE}" >> "${MANIFEST_RUN_APP}"
echo "Spring-Boot-Version: ${SPRING_BOOT_VERSION}" >> "${MANIFEST_RUN_APP}"
echo "Build-Jdk-Spec: ${BUILD_JDK_SPEC}" >> "${MANIFEST_RUN_APP}"
echo "Class-Path: application/$(basename "$JAREXE")" >> "${MANIFEST_RUN_APP}"
cut -d '/' -f 3 < "${UNPACK_TMPDIR}/BOOT-INF/classpath.idx" | cut -d '"' -f 1 | while IFS= read -r lib
do
  cp -r "${UNPACK_TMPDIR}/BOOT-INF/lib/${lib}" "${DESTINATION}/dependencies/"
  echo "  dependencies/$lib" >> "${MANIFEST_RUN_APP}"
done

if (( ${#ADDITIONAL[@]} )); then
  mkdir -p "${DESTINATION}/ext"
  for jar in $ADDITIONAL
  do
    cp "$jar" "${DESTINATION}/ext"
    echo "  ext/$jar" >> "${MANIFEST_RUN_APP}"
  done
fi

jar cfm "${DESTINATION}/run-app.jar" "${MANIFEST_RUN_APP}"

if [ -z "$QUIET" ]; then
echo "Application successfully extracted to '${DESTINATION}'

      To start the application from that directory:

      $ java -jar run-app.jar

      TIP: To improve startup performance, you can create a CDS Archive with a single training run:

      $ java -XX:ArchiveClassesAtExit=application.jsa -Dspring.context.exit=onRefresh -jar run-app.jar

      Then use the generated cache:

      $ java -XX:SharedArchiveFile=application.jsa -jar run-app.jar

      See https://docs.spring.io/spring-framework/reference/integration/class-data-sharing.html for more details."
fi
