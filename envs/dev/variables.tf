variable "project" {
    type = string
}

variable "vpc_cidr" {
  type    = string
}
variable "public_cidrs" {
    type = list(string)
}

variable "private_cidrs" {
    type = list(string)
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "alert_email" {
  type = string
}

variable "region" {
    type = string
}

variable "app_port" {
    type    = number  
}

variable "min_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number  
}

variable "ami_id" {
  type = string
}