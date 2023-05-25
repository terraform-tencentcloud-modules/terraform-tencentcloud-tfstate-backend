output "bucket_id" {
  value = module.cos_bucket.bucket_id
  description = "The ID of the bucket."
}

output "bucket_url" {
  value = module.cos_bucket.bucket_url
  description = "The URL of this cos bucket."
}

output "bucket_policy_id" {
  value = module.cos_bucket.bucket_policy_id
  description = "The ID of the bucket policy."
}