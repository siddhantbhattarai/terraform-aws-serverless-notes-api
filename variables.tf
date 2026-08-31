variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "use_floci" {
  type    = bool
  default = false
}

variable "floci_endpoint" {
  type    = string
  default = "http://localhost:4566"
}
variable "project_name" {
  type    = string
  default = "serverless-notes"
}
variable "environment" {
  type    = string
  default = "dev"
}
