#!/bin/bash

# Function to destroy Terraform
terraform_destroy() {
  local dir=$1
  echo "Destroying Terraform in directory: $dir"
  cd "$dir" || exit
  terraform destroy -var-file="../terraform.tfvars" -auto-approve
  cd - > /dev/null || exit
}


# Destroy Terraform in all directories
terraform_destroy "rancher-multinode"
terraform_destroy "docker-node"
terraform_destroy "vpc"

echo "All Terraform commands executed successfully."
