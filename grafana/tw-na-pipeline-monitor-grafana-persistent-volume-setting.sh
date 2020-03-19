#!/bin/bash
oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/datasources/datasource.yaml --sub-path=datasource.yaml --name grafana-config --configmap-name grafana-configmap
oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/dashboards/dashboard.yaml --sub-path=dashboard.yaml --name dashboard-provider --configmap-name grafana-configmap
oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/dashboards/jenkins-metrics-dashboard.json --sub-path=jenkins-metrics-dashboard.json --name jenkins-metrics-dashboard --configmap-name grafana-configmap
