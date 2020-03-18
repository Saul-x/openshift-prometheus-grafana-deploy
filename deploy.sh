#!/bin/bash
oc delete all --selector app=tw-na-pipeline-monitor-grafana &&
oc delete all --selector app=tw-na-pipeline-monitor-prometheus &&
oc apply -f tw-na-pipeline-monitor-grafana-build.yaml &&
oc start-build tw-na-pipeline-monitor-grafana-build --from-dir grafana &&
oc log bc/tw-na-pipeline-monitor-grafana-build --follow &&
oc new-app prom/prometheus --name=tw-na-pipeline-monitor-prometheus &&
sh prometheus/tw-na-pipeline-monitor-prometheus-deploy-patch.sh &&
oc new-app tw-na-pipeline-monitor-grafana &&
oc expose svc/tw-na-pipeline-monitor-grafana &&
oc expose svc/tw-na-pipeline-monitor-prometheus &&
oc apply -f prometheus/tw-na-pipeline-monitor-prometheus-resource.yaml &&
sh prometheus/tw-na-pipeline-monitor-prometheus-persistent-volume-setting.sh &&
oc set volume --add dc/tw-na-pipeline-monitor-prometheus -t=configmap -m /etc/prometheus/prometheus.yml --sub-path=prometheus.yml --name prometheus-config --configmap-name prometheus-configmap --overwrite

