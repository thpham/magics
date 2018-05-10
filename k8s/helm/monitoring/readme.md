grafana: 5.0.4 chart 1.3.0
prometheus: 2.2.1 chart 6.3.3
alertmanager: 0.14.0

---

helm install -f prometheus.yaml --name prometheus --namespace monitoring --version 6.3.3 stable/prometheus 




---

helm install -f grafana.yaml --name grafana --namespace monitoring --version 1.3.0 stable/grafana
