#!/bin/bash

if [[ ! -f $DIST/idp.install.properties ]]; then
	SCOPE=docker HOST=tier-idp.$SCOPE ENTITYID=http://$HOST:8080/idp/shibboleth /install-shib.sh
fi

catalina.sh run
