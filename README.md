
You may need to login openshift and create a new project

```
oc login

oc new-app <your-app>
```

# Simple way to deploy grafana and prometheus

If you don't want to deploy the project step by step, you can just run it：
```
sh deploy.sh
```

## Prometheus deploy
1.new a app from pipeline monitor image which you build from last command

```
oc new-app prom/prometheus --name=tw-na-pipeline-monitor-prometheus
```

2.expose your service outside the openshift

```
oc expose svc/tw-na-pipeline-monitor-prometheus
```

3.mount a persistent volume to /prometheus which store the data of our prometheus (Data store path could be configured by --storage.tsdb.path)

```
Before you mount new volume to /prometheus, you should delete the initial empty volume
oc set volume dc/tw-na-pipeline-monitor-prometheus | grep as | awk -F 'as ' '{print $2}'|xargs -I {} oc set volume dc/tw-na-pipeline-monitor-prometheus --remove --name={}
oc set volume dc/tw-na-pipeline-monitor-prometheus --add --type pvc --claim-name monitor-data-pvc --mount-path /prometheus --name monitor-data --claim-size 1Gi
```

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

You can apply a configmap from prometheus/tw-na-pipeline-monitor-prometheus-resources.yaml which contain the config info of prometheus
```$xslt
 oc apply -f prometheus/tw-na-pipeline-monitor-prometheus-resources.yaml
```

then add config to dc/tw-na-pipeline-monitor-prometheus, prometheus.yml would mount to /etc/prometheus/:

```
oc set volume --add dc/tw-na-pipeline-monitor-prometheus -t=configmap -m /etc/prometheus/prometheus.yml --sub-path=prometheus.yml --name prometheus-config --configmap-name prometheus-configmap
```

**Remind: All command should execute in the project directory**

## Grafana deploy
1.new a app from pipeline monitor image which you build from last command

```
oc new-app grafana/grafana --name=tw-na-pipeline-monitor-grafana
```

2.expose your service outside the openshift

```
oc expose svc/tw-na-pipeline-monitor-grafana
```

3.I prepare some default config and a dashboard for grafana can connect the prometheus we build before
    You should create a config map first:
    
```    
oc apply -f grafana/tw-na-pipeline-monitor-grafana-resources.yaml
```
    
the content of this file which we use to create config map in above command include:
   
  1.dashboard.yaml, it is dashboard support, should be put into /etc/grafana/provisioning/datasources
        
  2.datasource.yaml, it is datasource config, should be put into /etc/grafana/provisioning/dashboard
        
  3.jenkins-metrics-dashboard.json, it is a json file contains a dashboard object, should be put into the directory which specify in dashboard.yaml, here is /etc/grafana/provisioning/datasources
        
so we should mount these file right:
    
```
    oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/datasources/datasource.yaml --sub-path=datasource.yaml --name grafana-config --configmap-name grafana-configmap
    oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/dashboards/dashboard.yaml --sub-path=dashboard.yaml --name dashboard-provider --configmap-name grafana-configmap
    oc set volume --add dc/tw-na-pipeline-monitor-grafana -t=configmap -m /etc/grafana/provisioning/dashboards/jenkins-metrics-dashboard.json --sub-path=jenkins-metrics-dashboard.json --name jenkins-metrics-dashboard --configmap-name grafana-configmap
```

**Remind: All command should execute in the project directory**
