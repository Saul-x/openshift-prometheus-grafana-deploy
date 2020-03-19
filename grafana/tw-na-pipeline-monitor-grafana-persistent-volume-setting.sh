#!/bin/bash

set -e
TW_NA_MONITOR_PVC=`oc get pvc | awk '{if(NR>1) print $1}' | grep monitor-data-pvc`
PESISTENT_VOLUME_MOUNT_COMMAND='oc set volume dc/tw-na-pipeline-monitor-prometheus --add --type pvc --claim-name monitor-data-pvc --mount-path /prometheus --name monitor-data'

# remove all psv of tw-na-pipeline-monitor-prometheus deploy config
oc set volume dc/tw-na-pipeline-monitor-prometheus | grep as | awk -F 'as ' '{print $2}'|xargs -I {} oc set volume dc/tw-na-pipeline-monitor-prometheus --remove --name={}

# add psv for tw-na-pipeline-monitor-prometheus, if 'monitor-data-pvc' doesn't exist, create it with --claim-size flag
if [ $TW_NA_MONITOR_PVC = 'monitor-data-pvc' ];
then
  eval "$PESISTENT_VOLUME_MOUNT_COMMAND"
else
  eval "$PESISTENT_VOLUME_MOUNT_COMMAND --claim-size=1Gi"
fi

#add config file to tw-na-pipeline-monitor-prometheus, the path is /etc/prometheus/prometheus.yml
oc set volume --add dc/tw-na-pipeline-monitor-prometheus -t=configmap -m /etc/prometheus/prometheus.yml --sub-path=prometheus.yml --name prometheus-config --configmap-name prometheus-configmap

oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/datasources/datasource.yaml --sub-path=datasource.yaml --name grafana-config --configmap-name grafana-configmap
oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/dashboards/dashboard.yaml --sub-path=dashboard.yaml --name dashboard-provider --configmap-name grafana-configmap
oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/dashboards/jenkins-metrics-dashboard.json --sub-path=jenkins-metrics-dashboard.json --name jenkins-metrics-dashboard --configmap-name grafana-configmap
