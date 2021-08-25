#!/bin/bash

set -e

DIRS=("deployment" "infra")

if ! [ -z "$1" ] && [ -d "$PWD/$1" ]; then
    DIRS=("$1")
else
    echo "Specified Terraform deployment folder not found ($1), exiting..."
    exit 1
fi

for dir in ${DIRS[@]};
do
    echo "-> Destroying '$dir' Terraform"
    pushd $dir
    terraform destroy -auto-approve
    popd
done

echo '-> Done destroying.'
