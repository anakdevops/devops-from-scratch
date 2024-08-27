#!/bin/bash



# Function to plan Terraform
terraform_plan() {
  local dir=$1
  echo "Planning Terraform in directory: $dir"
  cd "$dir" || exit
  terraform plan -var-file="../terraform.tfvars"
  cd - > /dev/null || exit
}







# Plan Terraform in all directories
terraform_plan "vpc"

terraform_plan "rancher-multinode"
terraform_plan "docker-node"




echo "All Terraform commands executed successfully."
