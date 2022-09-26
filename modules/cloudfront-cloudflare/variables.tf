variable "origin_hostname" {
  type = string
}

variable "hostnames" {
  description = "A map of hostname:domain"
  type = map(string)
}

variable "logging_bucket" {
  description = "S3 bucket for logs"
  type = string
  default = null
}

variable "aws_provider" {
  default = null
}
