resource "docker_image" "lambda_image" {
  triggers = {
    uuid = uuid()
  }

  name = "${local.ecr_repository_url}:latest"
  build {
    path = "../lambda"
    tag  = ["${local.ecr_repository_url}:latest"]
  }
}

resource "null_resource" "push_image" {
  triggers = {
    uuid = uuid()
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${split("/", local.ecr_repository_url)[0]}
      docker push ${local.ecr_repository_url}:latest
    EOT
  }

  depends_on = [
    docker_image.lambda_image
  ]
}
