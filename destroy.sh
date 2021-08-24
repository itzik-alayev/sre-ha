#!/bin/bash

echo '-> Destroying "deploy" terraform'
pushd deploy
terraform destroy -auto-approve
popd

echo '-> Destroying "infra" terraform'
pushd infra
terraform destroy -auto-approve
popd

echo '-> Environment destroyed.'
