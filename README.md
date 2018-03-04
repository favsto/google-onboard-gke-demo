# License

Copyright 2018 Injenia Srl

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Purpose
This is a demo project and its purpose is to show a simple Web Application running on a kubernetes architecture running on Google Kubernetes Engine.
The steps will ask you to:
- create a cluster GKE
- deploy and expose the application
- scale and update your service

# Requirements
- [a GCP account](https://cloud.google.com/free/)
- [a GCP project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project)
This demo can be run on Google [Google Cloud Shell](https://cloud.google.com/shell/docs/starting-cloud-shell), alternatively you need:
- [gcloud](https://cloud.google.com/sdk/downloads)
- node js

Make sure that your project has these APIs enabled:
- Google Compute Engine
- Google Container Registry
- Google Kubernetes Engine
- Google Cloud Storage

# How to run the demo

## Prepare your dev environment 
Enter your project with Google Cloud Console and open Google Cloud Shell console (top-right button). Clone this project on a folder into your home:
```shell
git clone https://github.com/favsto/google-onboard-gke-demo ./gke-demo
```
Create a kubernetes cluster called "onboard" with 3 nodes:
```shell
gcloud container clusters create onboard --num-nodes 3 --machine-type n1-standard-1 --zone europe-west1-d
```
Its creation will take some dozens of second, take some time to explore the content of server.js and Dockerfile in the meanwhile.

### Try the application locally
First of all, try to run the application locally on your shell, running:
```shell
node server.js 
curl http://localhost:8080
```

## The application container image
GKE will require a Docker image, visible in your GCP project. The first step towards this direction is to create a local (first version of) image:
```shell
# buold and tag your image with v1, mind the final dot
docker build -t gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1 .
```
Google Cloud Shell has a bunch of env variables, such as ```$DEVSHELL_PROJECT_ID``` that contains your project ID. 

### [optional] Test the image
You can test the image if you want to proceed step-by-step, eventually. Follow these steps:
```shell
# run the server on port 8080
docker run --rm -d -p 8080:8080 --name onboard-local gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1

# test your server
curl http://localhost:8080

# stop and remove the container
docker stop onboard-local
```

### Push your image into the project registry
Your registry of the project is initially empty. Push the first version of your image:
```shell
gcloud docker -- push gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1
```

## Run your first version
Create e deployment with your application, with one pod:
```shell
kubectl run onboard-k8s-demo \
    --image=gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1 \
    --port=8080
```
The Deployment will take care of the healthiness of your pods, scale either up or down it, update it and several other mechanisms. But it doesn't expose your application externally. For this purpose you need to use a Service:
```shell
kubectl expose deployment onboard-k8s-demo --type="LoadBalancer" \
    --port=80 --target-port=8080
```
You need to wait some seconds before the service will be ready. You can monitor it uup until you can see an external IP address, with:
```shell
kubectl get svc --watch
# press CTRL+C to exit

curl http://<ESTARNAL-IP>
# alternatively, you ca navigate http://<EXTERNAL-IP>/index.html
```

## Horizontal scaling 
Hence, it's time to scale your application up! We have only one pod running, currently. Let's scale up, but first - if you want to see the result in real-time - run this command in a different shell (you can use another non-cloud shell):
```shell
while sleep 1; do curl http://<EXTERNAL-IP>; echo; done
```
To scale to 4 pods:
```shell
kubectl scale deployment onboard-k8s-demo --replicas=4

# verify your deployment status with this
kubectl get deply
```

## Rolling update
Your application is up and running. But, what happens if you need to update your release? Lucky the Deployment has a mechanism for performing rolling update with ease, but first of all we need to bake a new version of our application.

Open the file ```server.js``` and change the value of the variable ```VERSION``` from "v1" to "v2". 
Now just create a new version of your image and push it on registry:
```shell
docker build -t gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2 .
gcloud docker -- push gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2
```
Please continue to see the curl loop you run previously or run it one more time. Now you can perform your rolling update:
```shell
kubectl set image deployment/onboard-k8s-demo \
    onboard-k8s-demo=gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2
```
You will see that your application still produce a result without errors but it slowly provide a new version.

# How to shut down the demo:
For cleaning everythig you created use these commands:
```shell
# delete k8s objects
kubectl delete service,deployment onboard-k8s-demo

# delete the cluster
gcloud container clusters delete onboard --zone=europe-west1-d

# remove GCR images
gcloud container images delete gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1
gcloud container images delete gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2
```

# Contact us
Feel free to interact with us, collaborate and improve this code. Please contact us via e-mail: iaas@injenia.it. Any contributor is my friend! :)