#!/bin/bash

rm key.pem
cd infrastructure/terraform/

terraform destroy -auto-approve