#!/bin/bash

set -e

# LAMBDA_IMAGE="006262944085.dkr.ecr.eu-central-1.amazonaws.com/sre-ha-lambda:latest"

# echo '-> Building lambda function Go handler...'
# pushd lambda
# docker build -t $LAMBDA_IMAGE .
# docker push $LAMBDA_IMAGE
# popd

echo '-> Applying "infra" terraform'
pushd infra
terraform init
terraform apply -auto-approve
popd

echo '-> Applying "deploy" terraform'
pushd deploy
terraform init
terraform apply -auto-approve -var="lambda_image=$LAMBDA_IMAGE"
popd

echo '-> Environment created'
