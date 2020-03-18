
You may need to login openshift and create a new project

```
oc login

oc new-app <your-app>
```


## Prometheus deploy
1.new a app from pipeline monitor image which you build from last command

`oc new-app prom/prometheus --name=tw-na-pipeline-monitor-prometheus`

2.expose your service outside the openshift

`oc expose svc/tw-na-pipeline-monitor-prometheus`

3.mount a persistent volume to /prometheus which store the data of our prometheus (Data store path could be configured by --storage.tsdb.path)

`oc set volumes dc/tw-na-pipeline-monitor-prometheus --add --mount-path=/prometheus --claim-size 1Gi`

  By default, --storage.tsdb.no-lockfile is false, It would lead certain error if multi-prometheus pod to lock same file in persistent volume, there are two example
   
   1.You set replica more than 1, and you would find only one pod had been deploy successfully
   
   2.You trigger re-deploy of the app, you will find the re-deploy can not work, because the old pod has been lock the persistent volume, and the new one want to lock the persistent volume too!

  So I set the --storage.tsdb.no-lockfile as true, and limit the max replica of prometheus number as 1
  
```shell script

# pass container parameter when deploy
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

# limit max pod number
    oc autoscale dc/tw-na-pipeline-monitor-prometheus --max 1
``` 

4.If you want config prometheus with customize prometheus.yml, you can create a configmap and mount config info to /etc/prometheus/prometheus.yml

You can create a configmap from a file which contain the config info of prometheus
```$xslt
 oc create configmap prometheus-configmap --from-file prometheus/prometheus.yml
```

then add it to dc/tw-na-pipeline-monitor-prometheus, prometheus.yml would mount to /etc/prometheus/:

`oc set volume --add dc/tw-na-pipeline-monitor-prometheus -t=configmap -m /etc/prometheus/prometheus.yml --sub-path=prometheus.yml --name prometheus-config --configmap-name prometheus-configmap`

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
