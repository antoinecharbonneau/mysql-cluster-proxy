#!/bin/bash

cd infrastructure/terraform/

terraform init
terraform apply -auto-approve
terraform output -raw key_pair| cat  > ../../key.pem; echo "" >> ../../key.pem

chmod 0600 ../../key.pem