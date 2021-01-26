Role Grafana
============
Grafana installer
Append datasources:

```yaml
grafana_datasources:
  - name: prometheus
    type: prometheus
    url: "http://localhost:9090"
```
Append dashboards from file:

```yaml
grafana_dashboards:
  - name: node_exporter
    file: dashboards/node_exporter.json
```
Example Playbook
----------------

    - hosts: servers
      roles:
        - role: RaibeartRuadh.grafana
          grafana_datasources:
            - name: prometheus
              type: prometheus
              url: "http://localhost:9090"
          grafana_dashboards:
            - name: node_exporter
              file: dashboards/node_exporter.json

