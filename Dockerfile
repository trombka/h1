FROM openjdk:12 AS build
RUN yum install -y git wget && rm -r /var/cache/yum/*
RUN git clone -b tmp https://github.com/TouK/hermes.git
WORKDIR hermes
RUN ./gradlew distZip -Pdistribution -x test

FROM openjdk:alpine as frontend
RUN apk update && apk add bash unzip && rm -r /var/cache/apk/*
COPY --from=build /hermes/hermes-frontend/build/distributions/* .
RUN unzip -q *.zip -d /opt
CMD /opt/hermes-frontend-1.4.0/bin/hermes-frontend

FROM openjdk:alpine as management
RUN apk update && apk add bash unzip && rm -r /var/cache/apk/*
COPY --from=build /hermes/hermes-management/build/distributions/* .
RUN unzip -q *.zip -d /opt
CMD /opt/hermes-management-1.4.1-tmp-SNAPSHOT/bin/hermes-management

FROM openjdk:alpine as consumers
RUN apk update && apk add bash unzip && rm -r /var/cache/apk/*
COPY --from=build /hermes/hermes-consumers/build/distributions/* .
RUN unzip -q *.zip -d /opt
CMD /opt/hermes-consumers-1.4.0-SNAPSHOT/bin/hermes-consumers

