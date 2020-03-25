#!/usr/bin/env bash -e

docker rm -f elastic-helm-charts-certs || true
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12 || true

ELASTIC_NAMESPACE=${ELASTIC_NAMESPACE:=default}
ELASTIC_VERSION=${ELASTIC_VERSION:=7.6.1}
ELASTIC_PASSWORD=$([ ! -z "$ELASTIC_PASSWORD" ] && echo $ELASTIC_PASSWORD || echo $(env LC_CTYPE=C tr -cd '[:alnum:]' < /dev/urandom | head -c20))

docker run --name elastic-helm-charts-certs -i -w /app \
    registry.cn-shanghai.aliyuncs.com/hsc-public/elasticsearch:$ELASTIC_VERSION \
    /bin/sh -c " \
        elasticsearch-certutil ca --out /app/elastic-stack-ca.p12 --pass '' && \
        elasticsearch-certutil cert --name security-master --dns security-master --ca /app/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /app/elastic-certificates.p12"

docker cp elastic-helm-charts-certs:/app/elastic-certificates.p12 ./
docker rm -f elastic-helm-charts-certs
openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem

kubectl -n $ELASTIC_NAMESPACE create secret generic elastic-certificates --from-file=elastic-certificates.p12
kubectl -n $ELASTIC_NAMESPACE create secret generic elastic-certificate-pem --from-file=elastic-certificate.pem
kubectl -n $ELASTIC_NAMESPACE create secret generic elastic-credentials --from-literal=password=$ELASTIC_PASSWORD --from-literal=username=elastic

rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12