FROM bellsoft/liberica-openjdk-debian:21.0.1-cds as build
COPY . /data/
RUN apt-get install --no-install-recommends -y unzip
RUN cd /data && ./appcds.sh -b

FROM bellsoft/liberica-openjdk-debian:21.0.1-cds
COPY --from=build /data/build/libs/application /data/build/libs/application
COPY --from=build /data/build/libs/dependencies /data/build/libs/dependencies
COPY --from=build /data/build/libs/run-app.jar /data/build/libs/run-app.jar
COPY --from=build /data/build/libs/run-app.jsa /data/build/libs/run-app.jsa
COPY --from=build /data/appcds.sh /data/appcds.sh

WORKDIR /data
ENTRYPOINT ./appcds.sh -s
