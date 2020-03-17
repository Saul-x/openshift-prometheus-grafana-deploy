#!/bin/bash
oc delete all --selector app=tw-na-pipeline-monitor-grafana &&
oc delete all --selector app=tw-na-pipeline-monitor-prometheus &&
oc apply -f tw-na-pipeline-monitor-prometheus-build.yaml &&
oc apply -f tw-na-pipeline-monitor-grafana-build.yaml &&
oc start-build tw-na-pipeline-monitor-grafana-build --from-dir grafana &&
oc log bc/tw-na-pipeline-monitor-grafana-build --follow &&
oc start-build tw-na-pipeline-monitor-prometheus-build --from-dir prometheus &&
oc log bc/tw-na-pipeline-monitor-prometheus-build --follow &&
oc new-app tw-na-pipeline-monitor-prometheus &&
oc new-app tw-na-pipeline-monitor-grafana &&
oc expose svc/tw-na-pipeline-monitor-grafana &&
oc expose svc/tw-na-pipeline-monitor-prometheus &&
oc set volumes dc/tw-na-pipeline-monitor-prometheus --add --overwrite --mount-path=/prometheus --claim-size 1Gi

