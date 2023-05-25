terraform {
  backend "cos" {
    region = "${region}"
    bucket = "${bucket}"
    prefix = "${prefix}"
  }
}
