locals {
  terraform_backend_config_file = format(
      "%s/%s",
      var.terraform_backend_config_file_path,
      var.terraform_backend_config_file_name
  )

  terraform_backend_config_template_file = "${path.module}/templates/terraform.tf.tpl"

  terraform_backend_config_content = templatefile(local.terraform_backend_config_template_file, {
    region = var.region
    # Template file inputs cannot be null, so we use empty string if the variable is null
    bucket = try(module.cos_bucket.bucket_id, "")
    prefix = var.cos_file_prefix == null ? "" : var.cos_file_prefix
  })

}

module "cos_bucket" {
  source               = "terraform-tencentcloud-modules/cos/tencentcloud"
  version              = "0.3.0"
  create_bucket        = var.create_bucket
  bucket_name          = var.bucket_name
  appid                = var.appid
  bucket_acl           = var.bucket_acl
  multi_az             = var.multi_az
  create_bucket_policy = var.create_bucket_policy
  policy               = var.policy
  force_clean          = true

  log_enable           = var.log_enable
  log_prefix           = var.log_prefix
  log_target_bucket    = var.log_target_bucket

  replica_role         = var.replica_role

  replica_rules        = var.replica_rules

  versioning_enable    = var.versioning_enable
  tags                 = var.tags
}


resource "local_file" "terraform_backend_config" {
  count           = var.terraform_backend_config_file_path != "" ? 1 : 0
  content         = local.terraform_backend_config_content
  filename        = local.terraform_backend_config_file
  file_permission = "0644"
}