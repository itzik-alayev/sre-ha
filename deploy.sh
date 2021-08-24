#!/bin/bash

set -e

echo '-> Applying "infra" terraform'
pushd infra
terraform init
terraform apply -auto-approve
popd

echo '-> Applying "deploy" terraform'
pushd deploy
terraform init
terraform apply -auto-approve
popd

echo '-> Environment created'
