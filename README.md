# TencentCloud Tfstate Backend Module for Terraform

## terraform-tencentcloud-tfstate-backend

A terraform module to provision an cos bucket to store terraform.tfstate file 

The following modules are included.
* [cos](https://registry.terraform.io/modules/terraform-tencentcloud-modules/cos/tencentcloud/latest)

The following resources are included.

* [tencentcloud_cos_bucket](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cos_bucket)
* [tencentcloud_cos_bucket_policy](https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs/resources/cos_bucket_policy)
* [local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)

These features of SCF configurations are supported:
- Provision an cos bucket to store terraform.tfstate file 
- Manages cos bucket log delivery
- Enable replication for the bucket
- Set the Policy permission for the bucket


Usage
-----
### Create 
Follow this procedure just once to create your deployment.

1. Add the `tfstate-backend` module to your `main.tf` file. The
   comment will help you remember to follow this procedure in the future:
   ```hcl
   module "tfstate_backend" {
     source = "terraform-tencentcloud-modules/tfstate-backend/tencentcloud"
     # Cloud Posse recommends pinning every module to a specific version
     # version     = "x.x.x"
     region               = var.region
     create_bucket        = var.create_bucket
     bucket_name          = var.bucket_name
     appid                = local.appid
     bucket_acl           = var.bucket_acl
     multi_az             = var.multi_az
     versioning_enable    = true
     tags                 = var.tags

     terraform_backend_config_file_path = "."
     terraform_backend_config_file_name = "backend.tf"
   }

   ```
   Module inputs `terraform_backend_config_file_path` and
   `terraform_backend_config_file_name` control the name of the backend
   definition file. Note that when `terraform_backend_config_file_path` is
   empty (the default), no file is created.

1. `terraform init`. This downloads Terraform modules and providers.

1. `terraform apply -auto-approve`. This creates the state bucket, along with anything else you have defined in your `*.tf` file(s). At
   this point, the Terraform state is still stored locally.

   Module `tfstate-backend` also creates a new `backend.tf` file
   that defines the Cos state backend. For example:
   ```hcl
   terraform {
     backend "cos" {
       region = "ap-guangzhou"
       bucket = "testbac-1314885289"
       prefix = "cos_file_prefix"
     }
   }
   ```

   Henceforth, Terraform will also read this newly-created backend definition
   file.

1. `terraform init -force-copy`. Terraform detects that you want to move your
   Terraform state to the Cos backend, and it does so per `-auto-approve`. Now the
   state is stored in the Cos bucket.

This concludes the one-time preparation. Now you can extend and modify your
Terraform configuration as usual.

### Destroy

Follow this procedure to delete your deployment.

1. In `main.tf`, change the `tfstate-backend` module arguments as
   follows:
   ```hcl
    module "tfstate_backend" {
      # ...
      terraform_backend_config_file_path = ""
      terraform_backend_config_content   = ""
      force_clean                        = true
    }
    ```
1. `terraform apply  -auto-approve`.
   This implements the above modifications by deleting the `backend.tf` file
   and enabling deletion of the Cos state bucket.
1. `terraform init -force-copy`. Terraform detects that you want to move your
   Terraform state from the Cos backend to local files, and it does so per
   `-auto-approve`. Now the state is once again stored locally and the Cos
   state bucket can be safely deleted.
1. `terraform destroy`. This deletes all resources in your deployment.
1. Examine local state file `terraform.tfstate` to verify that it contains
   no resources.

<br/>

## Examples:

- [Complete](https://github.com/terraform-tencentcloud-modules/terraform-tencentcloud-scf/tree/main/examples/complete) - A complete example of SCF features


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_tencentcloud"></a> [tencentcloud](#requirement\_tencentcloud) | >= 1.18.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tencentcloud"></a> [tencentcloud](#provider\_tencentcloud) | >= 1.18.1 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | The current region. | string | "" | Yes
| create_bucket | Controls if COS bucket should be created. | bool | true | no
| create_bucket_policy | Controls if COS bucket policy should be created. | bool | false | no
| appid | Your appid. | string | "" | no
| bucket_name | The name of the bucket. | string | "" | no
| bucket_acl | Access control list for the bucket. | string | "private" | no
| acl_body |The XML format of Access control list for the bucket. see resource tencentcloud_cos_bucket.| string | null | no
| encryption_algorithm | The server-side encryption algorithm to the bucket. | string | "AES256" | no
| force_clean | Whether to force cleanup all objects before delete bucket. | bool | false | no
| log_enable | Indicate the access log of this bucket to be saved or not. | bool | false | no
| log_prefix | The prefix log name which saves the access log of this bucket per 5 minutes. Eg. MyLogPrefix/. The log access file format is log_target_bucket/log_prefix{YYYY}/{MM}/{DD}/{time}{random}{index}.gz. Only valid when log_enable is true. | string | "" | no
| log_target_bucket | The target bucket name which saves the access log of this bucket per 5 minutes. The log access file format is log_target_bucket/log_prefix{YYYY}/{MM}/{DD}/{time}{random}{index}.gz. Only valid when log_enable is true. User must have full access on this bucket.| string | "" | no
| multi_az | Indicates whether to create a bucket of multi available zone. NOTE: If set to true, the versioning must enable. | bool | false | no
| replica_role | Request initiator identifier, format: qcs::cam::uin/<owneruin>:uin/<subuin>. NOTE: only versioning_enable is true can configure this argument. | string | "" | no
| replica_rules | List of replica rule. NOTE: only versioning_enable is true and replica_role set can configure this argument. see resource tencentcloud_cos_bucket.| list(map(string)) | [] | no
| versioning_enable | Enable bucket versioning. | bool | false | no
| tags | A mapping of tags to assign to the bucket.| map(string) | {} | no
| policy | The text of the policy.see resource tencentcloud_cos_bucket. | string | "" | no
| terraform_backend_config_file_path | Directory for the terraform backend config file, usually `.`. The default is to create no file. | string | "" | no
| terraform_backend_config_file_name | Name of terraform backend config file to generate.| string | "" | no
| cos_file_prefix | The directory for saving the state file in bucket. | string | "" | no

### function_trigger_config
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the SCF function trigger, if type is ckafka, the format of name must be <ckafkaInstanceId>-<topicId>; if type is cos, the name is cos bucket id, other In any case, it can be combined arbitrarily. It can only contain English letters, numbers, connectors and underscores. The maximum length is 100. | string | "" | yes
| trigger_desc | TriggerDesc of the SCF function trigger, parameter format of timer is linux cron expression; parameter of cos type is json string {"bucketUrl":"<name-appid>.cos.<region>.myqcloud.com","event":"cos:ObjectCreated:*","filter":{"Prefix":"","Suffix":""}}, where bucketUrl is cos bucket (optional), event is the cos event trigger, Prefix is the corresponding file prefix filter condition, Suffix is the suffix filter condition, if not need filter condition can not pass; cmq type does not pass this parameter; ckafka type parameter format is json string {"maxMsgNum":"1","offset":"latest"}; apigw type parameter format is json string {"api":{"authRequired":"FALSE","requestConfig":{"method":"ANY"},"isIntegratedResponse":"FALSE"},"service":{"serviceId":"service-dqzh68sg"},"release":{"environmentName":"test"}}. | string | "" | yes
| type | Type of the SCF function trigger, support cos, cmq, timer, ckafka, apigw.| string | "" | no
| cos_region | Region of cos bucket. if type is cos, cos_region is required. | string | "" | no

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The ID of the bucket.|
| bucket_url | The URL of this cos bucket. |
| bucket_policy_id | The ID of the bucket policy. |

## Authors

Created and maintained by [TencentCloud](https://github.com/terraform-providers/terraform-provider-tencentcloud)

## License

Mozilla Public License Version 2.0.
See LICENSE for full details.
