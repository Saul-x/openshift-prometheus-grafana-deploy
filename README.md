## Prometheus deploy

You may need to login openshift and create a new project

`oc login`
`oc new-app <your-app>`

1.create build config of pipeline monitor prometheus:

`oc apply -f tw-na-pipeline-monitor-prometheus-build.yaml`

2.build a tw-na-pipeline-monitor image:

` oc start-build tw-na-pipeline-monitor-prometheus-build --from-dir prometheus`

3.new a app from pipeline monitor image which you build from last command
`oc new-app tw-na-pipeline-monitor-prometheus --name=prometheus`

4.expose your service outside the openshift
`oc expose svc/tw-na-pipeline-monitor-prometheus`
