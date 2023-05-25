# A complete example of tfstate-backend



## Usage
### Create 
To run this example you need to execute:

```bash
$ terraform init
$ terraform  plan  -var-file=test.tfvars
$ terraform apply  -var-file=test.tfvars
$ terraform init -force-copy
```

### Destroy 
Change the value of terraform_backend_config_file_path to "". and  run this example you need to execute:

```bash
$ terraform apply  -var-file=test.tfvars
$ terraform init -force-copy
$ terraform destroy -var-file=test.tfvars
```

Note that this example may create resources which cost money. Run `terraform destroy -var-file=test.tfvars` when you don't need these
 resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
