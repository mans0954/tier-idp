# Environment variables required for script:
# 
# SCOPE #scope for scoped attributes e.g. example.org
# HOST  #f.q.d.n. e.g. hostname.example.org
# ENTITYID # SAML entity id e.g. http://f.q.d.n/idp/shibboleth

#
# Install shibboleth IDP
#
export KEYPASS=changeit
export SEALPASS=changeit
cd /usr/local/dist
echo \# Properties controlling the installation of the Shibboleth IdP>$DIST/idp.install.properties
export SFILE=$DIST/idp.merge.properties
echo idp.scope=$SCOPE>>$SFILE
echo idp.entityID=$ENTITYID>>$SFILE
echo idp.sealer.storePassword=$SEALPASS>>$SFILE
echo idp.sealer.keyPassword=$SEALPASS>>$SFILE
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

chgrp -R root $IDP_HOME
chmod -R g+r $IDP_HOME
chmod g+w $IDP_HOME/logs
chmod g+s $IDP_HOME/logs

cp /build-configs/idp.xml /usr/local/tomcat/conf/Catalina/localhost/

sed -i 's/https:\/\/$HOST\//http:\/\/$HOST:8080\//' /opt/shibboleth-idp/metadata/idp-metadata.xml

rm /opt/shibboleth-idp/conf/relying-party.xml /opt/shibboleth-idp/conf/authn/password-authn-config.xml
ln -s /etc/shibboleth-idp/relying-party.xml /opt/shibboleth-idp/conf/relying-party.xml 
ln -s /etc/shibboleth-idp/authn/password-authn-config.xml /opt/shibboleth-idp/conf/authn/password-authn-config.xml 

