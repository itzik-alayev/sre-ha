resource "aws_iam_role" "eks_lambda" {
  name = "eks_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-lambda-role"
  }
}

resource "aws_iam_role_policy" "eks_lambda_iam_policy" {
  name = "eks_lambda_iam_policy"
  role = aws_iam_role.eks_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:GetCallerIdentity",
          "eks:DescribeCluster"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}