
You may need to login openshift and create a new project

```
oc login

oc new-app <your-app>
```


## Prometheus deploy
1.create build config of pipeline monitor prometheus:

`oc apply -f tw-na-pipeline-monitor-prometheus-build.yaml`

2.build a tw-na-pipeline-monitor image:

` oc start-build tw-na-pipeline-monitor-prometheus-build --from-dir prometheus`

3.new a app from pipeline monitor image which you build from last command

`oc new-app tw-na-pipeline-monitor-prometheus`

4.expose your service outside the openshift

`oc expose svc/tw-na-pipeline-monitor-prometheus`

**Remind: All command should execute in the project directory**

## Grafana deploy
1.create build config of pipeline monitor grafana:

`oc apply -f tw-na-pipeline-monitor-grafana-build.yaml`

2.build a tw-na-pipeline-monitor image:

` oc start-build tw-na-pipeline-monitor-grafana-build --from-dir grafana`

3.new a app from pipeline monitor image which you build from last command

`oc new-app tw-na-pipeline-monitor-grafana`

4.expose your service outside the openshift

`oc expose svc/tw-na-pipeline-monitor-grafana`

**Remind: All command should execute in the project directory**

#Simple way to deploy grafana and prometheus

just run it：
`sh deploy.sh`
