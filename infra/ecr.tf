resource "aws_ecr_repository" "lambda_image" {
  name = "${var.cluster_name}-lambda"
}
