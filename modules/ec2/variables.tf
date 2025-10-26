variable "instance_type" {
    type = string  
    default = "t3.micro" 
}
variable "ami_id"        { 
    type = string  
    default = null
}
variable "ec2_sg_id"     { 
    type = string
}

variable "project" {
    type = string
}

