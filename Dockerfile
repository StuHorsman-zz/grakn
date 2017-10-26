FROM ubuntu:xenial

## shutup debconf
ARG DEBIAN_FRONTEND=noninteractive

## install java
RUN apt-get update && apt-get install -y \
  software-properties-common \
  python-software-properties \
  maven \
  curl \
  unzip \
  && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
  && add-apt-repository -y ppa:webupd8team/java \
  && apt-get update \
  && apt-get install -y oracle-java8-installer \
  && rm -rf /var/lib/apt/lists/* /var/cache/oracle-jdk8-installer

## define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

## add tini
ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

## install grakn
ENV GRAKN_VERSION 0.16.0
RUN curl -SL -o /tmp/grakn.zip https://github.com/graknlabs/grakn/releases/download/v${GRAKN_VERSION}/grakn-dist-${GRAKN_VERSION}.zip \
  && unzip -d /data /tmp/grakn.zip \
  && ln -s /data/grakn-dist-${GRAKN_VERSION} /data/grakn \
  && rm /tmp/grakn.zip

## define working directory
WORKDIR /data/grakn

## expose dashboard
EXPOSE 4567

## define default command
COPY init /init
RUN chmod +x /init
ENTRYPOINT ["/tini", "--"]
CMD ["/init"]
