variable "ami_id" {
  description = "Value of the AMI id for the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "Value of the type for the EC2 instance"
  type        = string
}
variable "subnets_quantity" {
  description = "Value of the subnets quantity"
  type        = number
  default     = 2
}