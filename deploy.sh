#!/bin/bash

set -e

DIRS=("infra" "deployment")

if ! [ -z "$1" ]; then
    if [ -d "$PWD/$1" ]; then
        DIRS=("$1")
    else
        echo "Specified Terraform deployment folder not found ($1), exiting..."
        exit 1
    fi
fi

for dir in ${DIRS[@]};
do
    echo "-> Applying '$dir' Terraform"
    pushd $dir
    terraform init
    terraform apply -auto-approve
    popd
done

echo '-> Done deploying.'
