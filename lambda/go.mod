module sre-ha-lambda

go 1.16

require (
	github.com/aws/aws-lambda-go v1.26.0
	github.com/aws/aws-sdk-go v1.40.28
	k8s.io/apimachinery v0.22.1
	k8s.io/client-go v0.22.1
	sigs.k8s.io/aws-iam-authenticator v0.5.3
)
