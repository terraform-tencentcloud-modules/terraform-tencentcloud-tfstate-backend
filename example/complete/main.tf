locals{
   appid      = data.tencentcloud_user_info.this.app_id
   log_bucket = "testlbg-${local.appid}"
}

data "tencentcloud_user_info" "this" {}

resource "tencentcloud_cam_role" "cosLogGrant" {
  name     = "CLS_QcsRole"
  document = <<EOF
{
  "version": "2.0",
  "statement": [
    {
      "action": [
        "name/sts:AssumeRole"
      ],
      "effect": "allow",
      "principal": {
        "service": [
          "cls.cloud.tencent.com"
        ]
      }
    }
  ]
}
EOF

  description = "cos log enable grant"
}

data "tencentcloud_cam_policies" "cosAccess" {
  name = "QcloudCOSAccessForCLSRole"
}

resource "tencentcloud_cam_role_policy_attachment" "cosLogGrant" {
  role_id   = tencentcloud_cam_role.cosLogGrant.id
  policy_id = data.tencentcloud_cam_policies.cosAccess.policy_list.0.policy_id
}

resource "tencentcloud_cos_bucket" "logBucket" {
  bucket            = local.log_bucket
  acl               = "private"
  versioning_enable = true
  force_clean       = true
}
# Setting log status end

# Using replication begin
resource "tencentcloud_cos_bucket" "replica" {
  bucket            = "tf-replica-foo-${data.tencentcloud_user_info.this.app_id}"
  acl               = "private"
  versioning_enable = true
  force_clean       = true
}
# Using replication  end

module "tfstate_backend" {
   source               = "../../"
   region               = var.region
   create_bucket        = var.create_bucket
   bucket_name          = var.bucket_name
   appid                = local.appid
   bucket_acl           = var.bucket_acl
   multi_az             = var.multi_az

   create_bucket_policy = true
   policy               = <<EOF
                                {
                                     "Statement": [
                                       {
                                         "Principal": {
                                           "qcs": [
                                             "qcs::cam::uin/${data.tencentcloud_user_info.this.owner_uin}:uin/${data.tencentcloud_user_info.this.uin}"
                                           ]
                                         },
                                         "Effect": "allow",
                                         "Action": [
                                           "name/cos:GetBucket"
                                         ],
                                         "Resource": [
                                             "qcs::cos:ap-guangzhou:uid/${local.appid}:${var.bucket_name}-${local.appid}/*"
                                         ]
                                       }
                                     ],
                                     "version": "2.0"
                                }
                                EOF
   force_clean          = true

   log_enable           = var.log_enable
   log_target_bucket    = local.log_bucket
   log_prefix           = var.log_prefix

   replica_role         = "qcs::cam::uin/${data.tencentcloud_user_info.this.owner_uin}:uin/${data.tencentcloud_user_info.this.uin}"
   replica_rules        = [{
                            id                 = "test-rep1"
                            status             = "Enabled"
                            prefix             = "dist"
                            destination_bucket = "qcs::cos:${var.region}::${tencentcloud_cos_bucket.replica.bucket}"
                          }]
   versioning_enable    = true
   tags                 = var.tags

   terraform_backend_config_file_path = ""
   terraform_backend_config_file_name = ""
   cos_file_prefix                    = var.cos_file_prefix

}



