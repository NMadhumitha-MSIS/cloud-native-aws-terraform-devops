variable "profile" {
  type        = string
  description = "AWS profile"
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for custom VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs for subnets"
  type        = list(string)
}
variable "db_host" {
  description = "Host address for the database"
  type        = string
  default     = "localhost"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "csye6225"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "db_username" {
  description = "Master DB username"
  type        = string
}

variable "db_password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "AMI ID of the custom image"
  type        = string
}

variable "app_port" {
  description = "App port to allow in SG"
  type        = number
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}
variable "instance_type" {
  description = "instance type ame"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB and ASG"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for ALB and target group"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "acm_cert_arn" {
  description = "ACM certificate ARN to use for ALB"
  type        = string
}

resource "random_id" "policy_suffix" {
  byte_length = 4
}
