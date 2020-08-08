FROM openjdk:8-alpine

ENV APKTOOL_VERSION=2.4.0
RUN apk add --no-cache curl bash

WORKDIR /usr/local/bin

RUN curl -LO https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool && chmod +x apktool
RUN curl -L -o apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar && chmod +x apktool.jar
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

VOLUME ["/app"]
WORKDIR /app

COPY network_security_config.xml ./

ENTRYPOINT ["entrypoint.sh"]