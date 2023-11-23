FROM bellsoft/liberica-openjdk-debian:21.0.1-cds as build
COPY . /data/
RUN apt-get install --no-install-recommends -y unzip
RUN cd /data && ./appcds.sh -b

FROM bellsoft/liberica-openjdk-debian:21.0.1-cds
COPY --from=build /data/build/unpacked /data/build/unpacked
COPY --from=build /data/appcds.sh /data/appcds.sh

WORKDIR /data
ENTRYPOINT ./appcds.sh -s
