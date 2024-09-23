module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"
  user_data = file("${path.module}/app.sh")
}