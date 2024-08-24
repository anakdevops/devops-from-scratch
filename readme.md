```
Recommended Service Account roles:
Compute Admin
Network Management Admin
```

```
./init_terraform.sh
./manage_terraform.sh
./output_terraform.sh
./destroy_terraform.sh
```


# OR

```
terraform plan -var-file="../terraform.tfvars"
terraform apply -var-file="../terraform.tfvars" -auto-approve
terraform destroy -var-file="../terraform.tfvars" -auto-approve
```