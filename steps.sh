# show Google Cloud Shell and built in env variables
env | grep DEVSHELL

# clone github
git clone https://github.com/favsto/google-onboard-gke-demo ./gke-demo

# local test
node server.js 

# new local Docker image
docker build -t onboard-k8s-demo:v1 .

# test the server via Docker run
docker run --rm -d -p 8080:8080 --name onboard-local onboard-k8s-demo:v1
curl http://localhost:8080 ; echo # or via DevShell proxy

# stop the container
docker stop onboard-local

# push the image on Google Container Registry
docker build -t eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1 .
gcloud docker -- push eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1

# create a new GKE cluster, wait util its creation
gcloud container clusters create onboard --num-nodes 3 --machine-type n1-standard-1 --zone europe-west1-d

# create a new Deployment
kubectl run onboard-k8s-demo --image=eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1 --port=8080

# expose the application via a service
kubectl expose deployment onboard-k8s-demo --type="LoadBalancer" --port=80 --target-port=8080

# test it via browser or shell
curl http://EXTERNAL_IP

# scale horizontally 
while sleep 1; do curl http://EXTERNAL_IP ; echo; done

### SIDED FULLSCREEN ###

kubectl scale deployment onboard-k8s-demo --replicas=4

# make some changes to your application and change version to 2

# update your image locally and on registry
docker build -t eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2 . 
gcloud docker -- push eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2

# check the status of the application in a different shell (CTRL+Z to exit)
while sleep 1; do curl http://EXTERNAL_IP ; echo; done

# rolling update with the new version of the image
kubectl set image deployment/onboard-k8s-demo onboard-k8s-demo=eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2

