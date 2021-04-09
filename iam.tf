resource "aws_iam_role" "machine" {
  name = "machine-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "machine" {
  name_prefix = "machine-instance"
  role = aws_iam_role.machine.name
}

resource "aws_iam_role_policy_attachment" "test-attach" {
 # name       = "test-attachment"
  role      = aws_iam_role.machine.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
