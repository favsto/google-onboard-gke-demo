#!/bin/bash

kubectl delete service,deployment onboard-k8s-demo
gcloud container clusters delete onboard --zone=europe-west1-d
gcloud container images delete gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v1
gcloud container images delete gcr.io/$DEVSHELL_PROJECT_ID/onboard-k8s-demo:v2