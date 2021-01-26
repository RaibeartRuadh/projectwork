Role Prometheus
--------------
Prometheus installer
Role Variables
--------------
`prometheus_version` - version of Prometheus
`prometheus_jobs` - jobs configuration
Example Playbook
----------------
    - hosts: servers
      roles:
         - role: prometheus
           prometheus_version: 2.22.0
           prometheus_jobs:
             - name: node-prometheus
               static_configs:
                 targets:
                   - 'localhost:9090'
                   - 'localhost:9100'

License
-------
BSD
