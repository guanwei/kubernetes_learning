# 通过 Helm 部署应用

## 安装 prometheus-operator

```bash
$ helm upgrade -i prometheus-operator stable/prometheus-operator -f prometheus-operator.yaml --namespace monitoring
```

## 安装 ElasticSearch 和 Kibana

添加 `elastic` Helm 仓库

```bash
$ helm repo add elastic https://helm.elastic.co
```

运行 `elastic-elasticsearch_generate_secrets.sh`，创建 ElasticSearch secrets

```bash
$ ELASTIC_NAMESPACE=logging ELASTIC_PASSWORD=elastic ./elastic-elasticsearch_generate_secrets.sh
```

安装 ElasticSearch

```bash
$ helm upgrade -i elasticsearch elastic/elasticsearch -f elastic-elasticsearch.yaml --namespace logging
```

运行 `elastic-kibana_generate_secrets.sh`，创建 Kibana secrets

```bash
$ ELASTIC_NAMESPACE=logging ELASTIC_PASSWORD=elastic ./elastic-elasticsearch_generate_secrets.sh
```

安装 Kibana

```bash
$ helm upgrade -i kibana elastic/kibana -f elastic-kibana.yaml --namespace logging
```

### 安装 elasticsearch-exporter

```bash
$ helm upgrade -i elasticsearch-exporter stable/elasticsearch-exporter -f elasticsearch-exporter.yaml --namespace monitoring
```

创建 elasticsearch-exporter PrometheusRule

```bash
$ kubectl create -f elasticsearch-exporter-prometheusrule.yaml
```

### 创建 ElasticSearch grafana dashborad

```bash
$ kubectl create -f elasticsearch-grafana-dashborad.yaml
```
