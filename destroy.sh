#!/bin/bash

set -e

DIRS=("deploy" "infra")

for dir in ${DIRS[@]};
do
    echo "-> Destroying '$dir' terraform"
    pushd $dir
    terraform destroy -auto-approve
    popd
done

echo '-> Environment destroyed.'
