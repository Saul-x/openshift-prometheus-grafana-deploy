#!/bin/bash
oc patch dc/tw-na-pipeline-monitor-prometheus --type=json -p '
[
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/args",
    "value": [
      "--storage.tsdb.no-lockfile",
      "--config.file=/etc/prometheus/prometheus.yml",
      "--storage.tsdb.path=/prometheus",
      "--web.console.libraries=/usr/share/prometheus/console_libraries",
      "--web.console.templates=/usr/share/prometheus/consoles"
    ]
  }
]'
