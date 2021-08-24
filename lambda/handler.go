package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"

	"github.com/aws/aws-sdk-go/service/eks"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	"sigs.k8s.io/aws-iam-authenticator/pkg/token"
)

type HandlerResponse struct {
	Pods []string `json:"pods"`
}

func newClientset(cluster *eks.Cluster) (*kubernetes.Clientset, error) {
	log.Printf("%+v", cluster)
	gen, err := token.NewGenerator(true, false)
	if err != nil {
		return nil, err
	}
	opts := &token.GetTokenOptions{
		ClusterID: aws.StringValue(cluster.Name),
	}
	tok, err := gen.GetWithOptions(opts)
	if err != nil {
		return nil, err
	}
	ca, err := base64.StdEncoding.DecodeString(aws.StringValue(cluster.CertificateAuthority.Data))
	if err != nil {
		return nil, err
	}
	clientset, err := kubernetes.NewForConfig(
		&rest.Config{
			Host:        aws.StringValue(cluster.Endpoint),
			BearerToken: tok.Token,
			TLSClientConfig: rest.TLSClientConfig{
				CAData: ca,
			},
		},
	)
	if err != nil {
		return nil, err
	}
	return clientset, nil
}

func HandleRequest() (events.APIGatewayProxyResponse, error) {
	region := os.Getenv("AWS_REGION")
	eksName := os.Getenv("EKS_NAME")

	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(region),
	}))
	eksSvc := eks.New(sess)

	input := &eks.DescribeClusterInput{
		Name: aws.String(eksName),
	}
	result, err := eksSvc.DescribeCluster(input)
	if err != nil {
		log.Fatalf("Error calling DescribeCluster: %v", err)
	}

	clientset, err := newClientset(result.Cluster)
	if err != nil {
		log.Fatalf("Error creating clientset: %v", err)
	}

	pods, err := clientset.CoreV1().Pods("kube-system").List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		log.Fatalf("Error getting Pods in kube-system namespace: %v", err)
	}

	handlerResponse := HandlerResponse{}
	for _, p := range pods.Items {
		handlerResponse.Pods = append(handlerResponse.Pods, p.Name)
	}

	json, err := json.Marshal(handlerResponse)
	if err != nil {
		log.Fatalf("Failed to marshal handlerResponse: %v", err)
	}

	apiGatewayResponse := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       string(json),
	}

	return apiGatewayResponse, nil
}

func main() {
	lambda.Start(HandleRequest)
}
