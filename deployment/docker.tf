resource "null_resource" "build_push_image" {
  triggers = {
    uuid = uuid()
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${split("/", local.ecr_repository_url)[0]}
      docker build -t ${local.ecr_repository_url}:latest -f ../lambda/Dockerfile ../lambda
      docker push ${local.ecr_repository_url}:latest
    EOT
  }
}
