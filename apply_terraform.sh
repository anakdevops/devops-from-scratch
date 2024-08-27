#!/bin/bash




# Function to apply Terraform
terraform_apply() {
  local dir=$1
  echo "Applying Terraform in directory: $dir"
  cd "$dir" || exit
  terraform apply -var-file="../terraform.tfvars" -auto-approve
  cd - > /dev/null || exit
}






terraform_apply "vpc"

# Apply Terraform in all directories
terraform_apply "rancher-multinode"
terraform_apply "docker-node"



echo "All Terraform commands executed successfully."
