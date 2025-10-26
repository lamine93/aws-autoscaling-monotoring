variable "project" {
    type = string
}

variable "app_port" {
    type = number
}

variable "vpc_id" {
    type = string
}

variable "alb_sg_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string)
}
