## Prometheus deploy

You may need to login openshift and create a new project

`oc login`
`oc new-app <your-app>`

1.create build config of custom prometheus:

`oc apply -f custom-prometheus-build.yaml`

2.build a custom image:

` oc start-build custom-prometheus-build --from-dir prometheus`

3.new a app from custom image which you build from last command
`oc new-app custom-prometheus --name=prometheus`

4.expose your service outside the openshift
`oc expose svc/custom-prometheus`
