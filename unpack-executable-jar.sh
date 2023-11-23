#!/usr/bin/env bash
set -e

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "unpack-executable-jar.sh - unpack Spring Boot executable JAR in order to run"
      echo "the application efficiently and maximizing AppCDS effectiveness."
      echo " "
      echo "my-dir
            ├── application
            │   └── my-app-1.0.0-SNAPSHOT.jar
            ├── dependencies
            │   ├── ...
            │   ├── spring-context-6.1.0.jar
            │   ├── spring-context-support-6.1.0.jar
            │   ├── ...
            └── run-app.jar"
      echo " "
      echo "unpack-executable-jar.sh [options] application.jar"
      echo " "
      echo "options:"
      echo "-d directory              Create the files in directory"
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

jar cf "${DESTINATION}/application/$(basename "$JAREXE")" -C "${UNPACK_TMPDIR}/BOOT-INF/classes/" .

MANIFEST_RUN_APP="${UNPACK_TMPDIR}/MANIFEST-RUN-APP.MF"
MAIN_CLASS=$(grep "Start-Class:" "${UNPACK_TMPDIR}/META-INF/MANIFEST.MF" | cut -d ' ' -f 2)

echo "Manifest-Version: 1.0" > "${MANIFEST_RUN_APP}"
echo "Main-Class: ${MAIN_CLASS}" >> "${MANIFEST_RUN_APP}"
echo "Class-Path: application/$(basename "$JAREXE")" >> "${MANIFEST_RUN_APP}"
cut -d '/' -f 3 < "${UNPACK_TMPDIR}/BOOT-INF/classpath.idx" | cut -d '"' -f 1 | while IFS= read -r lib
do
  cp -r "${UNPACK_TMPDIR}/BOOT-INF/lib/${lib}" "${DESTINATION}/dependencies/"
  echo "  dependencies/$lib" >> "${MANIFEST_RUN_APP}"
done

jar cfm "${DESTINATION}/run-app.jar" "${MANIFEST_RUN_APP}"

