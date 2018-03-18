FROM   tomcat
MAINTAINER Christopher Hoskin "christopher.hoskin@gmail.com"
# Based on https://github.com/Internet2/tier-idp/
# Original Copyright and License unknown
# Modifications Copyright Christopher Hoskin
# Original Maintainer Mark McCahill "mark.mccahill@duke.edu"

USER root
ENV version=3.3.1

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y wget unzip

RUN cd /opt

#
# Shibboleth IDP
#
RUN set -e ; \
    mkdir /usr/local/dist ; \
    cd /usr/local/dist ; \
    wget http://shibboleth.net/downloads/identity-provider/${version}/shibboleth-identity-provider-${version}.tar.gz ; \
    wget http://shibboleth.net/downloads/identity-provider/${version}/shibboleth-identity-provider-${version}.tar.gz.asc ; \
    wget http://shibboleth.net/downloads/identity-provider/${version}/shibboleth-identity-provider-${version}.tar.gz.sha256 ; \
    wget https://shibboleth.net/downloads/PGP_KEYS ; \
    gpg --import PGP_KEYS ; \
    sha256sum --check shibboleth-identity-provider-${version}.tar.gz.sha256 ; \
    gpg shibboleth-identity-provider-${version}.tar.gz.asc ; \
    tar -xvzf shibboleth-identity-provider-${version}.tar.gz

ADD ./configs /build-configs

#
# Install shibboleth IDP
#
RUN export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 ; \
    export KEYPASS=changeit ; \
    export SEALPASS=changeit ; \
    export SCOPE=docker ; \
    export HOST=tier-idp.$SCOPE ; \
    export ENTITYID=http://$HOST:8080/idp/shibboleth ;  \
    cd /usr/local/dist ;  \
    export DIST=/usr/local/dist/shibboleth-identity-provider-${version} ; \
    export IDP_HOME=/opt/shibboleth-idp ; \
    echo \# Properties controlling the installation of the Shibboleth IdP>$DIST/idp.install.properties ; \
    export SFILE=$DIST/idp.merge.properties ; \
    echo idp.scope=$SCOPE>>$SFILE ; \
    echo idp.entityID=$ENTITYID>>$SFILE ; \
    echo idp.sealer.storePassword=$SEALPASS>>$SFILE ; \
    echo idp.sealer.keyPassword=$SEALPASS>>$SFILE ; \
    $DIST/bin/install.sh \
       -Didp.property.file=idp.install.properties \
       -Didp.merge.properties=idp.merge.properties \
       -Didp.src.dir=$DIST \
       -Didp.target.dir=$IDP_HOME \
       -Didp.scope=$SCOPE \
       -Didp.host.name=$HOST \
       -Didp.keystore.password=$KEYPASS \
       -Didp.sealer.password=$SEALPASS \
       -Didp.noprompt=true 

RUN IDP_HOME=/opt/shibboleth-idp ; \
    chgrp -R root $IDP_HOME ; \
    chmod -R g+r $IDP_HOME ; \
    chmod g+w $IDP_HOME/logs ; \
    chmod g+s $IDP_HOME/logs

#
# Install Java Server Tag Library
#
RUN wget https://build.shibboleth.net/nexus/service/local/repositories/thirdparty/content/javax/servlet/jstl/1.2/jstl-1.2.jar \
          -P /usr/share/tomcat/lib/

#
# Deploy to Tomcat
#
RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost/
RUN cp /build-configs/idp.xml /usr/local/tomcat/conf/Catalina/localhost/

RUN sed -i 's/https:\/\/tier-idp.docker\//http:\/\/tier-idp.docker:8080\//' /opt/shibboleth-idp/metadata/idp-metadata.xml

COPY relying-party.xml /opt/shibboleth-idp/conf/relying-party.xml
COPY password-authn-config.xml /opt/shibboleth-idp/conf/authn/password-authn-config.xml
COPY kerberos/krb5.conf /etc/krb5.conf

EXPOSE 8080
