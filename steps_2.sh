env | grep DEVSHELL

git clone https://github.com/favsto/google-onboard-gke-demo ./gke-demo

node server.js 

docker build -t onboard-k8s-demo:v1 .

docker run --rm -d -p 8080:8080 --name onboard-local onboard-k8s-demo:v1
curl http://localhost:8080 ; echo # or via DevShell proxy

docker stop onboard-local

docker build -t eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1 .
gcloud docker -- push eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1

gcloud container clusters create onboard --num-nodes 3 --machine-type n1-standard-1 --zone europe-west1-d

kubectl run onboard-k8s-demo --image=eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1 --port=8080

kubectl expose deployment onboard-k8s-demo --type="LoadBalancer" --port=80 --target-port=8080

curl http://EXTERNAL_IP

while sleep 1; do curl http://EXTERNAL_IP ; echo; done

# sided fs
kubectl scale deployment onboard-k8s-demo --replicas=4

# make some changes to your application and change version to 2

docker build -t eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2 . 
gcloud docker -- push eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2

while sleep 1; do curl http://EXTERNAL_IP ; echo; done

kubectl set image deployment/onboard-k8s-demo onboard-k8s-demo=eu.gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2
