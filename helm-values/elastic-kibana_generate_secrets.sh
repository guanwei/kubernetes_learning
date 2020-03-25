#!/usr/bin/env bash -e

KIBANA_VERSION=${KIBANA_VERSION:=7.6.1}
KIBANA_NAMESPACE=${KIBANA_NAMESPACE:=default}

KIBANA_ENCRYPTION_KEY=$(env LC_CTYPE=C tr -cd _A-Z-a-z-0-9 < /dev/urandom | head -c50)

kubectl -n $KIBANA_NAMESPACE create secret generic kibana --from-literal=encryptionkey=$KIBANA_ENCRYPTION_KEY