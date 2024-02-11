#!/usr/bin/env bash
set -e

docker run --rm -it -p 8080:8080 spring-cds-demo:1.0.0-SNAPSHOT
