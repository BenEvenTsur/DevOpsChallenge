resource "aws_instance" "server" {
  ami = "ami-0ee8244746ec5d6d4"
  instance_type = "t3.nano"
}