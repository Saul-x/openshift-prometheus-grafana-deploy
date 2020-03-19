#!/bin/bash
oc delete all --selector app=tw-na-pipeline-monitor-grafana &&
oc delete all --selector app=tw-na-pipeline-monitor-prometheus &&
oc new-app prom/prometheus --name=tw-na-pipeline-monitor-prometheus &&
sh prometheus/tw-na-pipeline-monitor-prometheus-deploy-patch.sh &&
oc new-app grafana/grafana --name=tw-na-pipeline-monitor-grafana &&
oc expose svc/tw-na-pipeline-monitor-grafana &&
oc expose svc/tw-na-pipeline-monitor-prometheus &&
oc apply -f prometheus/tw-na-pipeline-monitor-prometheus-resources.yaml &&
oc apply -f grafana/tw-na-pipeline-monitor-grafana-resources.yaml &&
sh prometheus/tw-na-pipeline-monitor-prometheus-persistent-volume-setting.sh

