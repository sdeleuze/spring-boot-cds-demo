FROM bellsoft/liberica-openjdk-debian:21.0.1-cds as build
COPY . /data/
RUN apt-get install --no-install-recommends -y unzip
RUN cd /data && ./cds.sh -b

FROM bellsoft/liberica-openjdk-debian:21.0.1-cds
COPY --from=build /data/build/unpacked /data/build/unpacked
COPY --from=build /data/cds.sh /data/cds.sh

WORKDIR /data
ENTRYPOINT ./cds.sh -s
