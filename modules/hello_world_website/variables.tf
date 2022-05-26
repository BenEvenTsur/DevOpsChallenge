variable "ami_id" {
  description = "Value of the AMI id for the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "Value of the type for the EC2 instance"
  type        = string
}
variable "http_port" {
  description = "Value of the HTTP port"
  type        = number
  default     = 80
}
variable "subnets_quantity" {
  description = "Value of the subnets quantity"
  type        = number
  default     = 2
}
variable "ec2_instances_quantity" {
  description = "Value of the EC2 quantity"
  type        = number
  default     = 1
}