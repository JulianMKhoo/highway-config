package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestTerraformNginxService(t *testing.T) {
	t.Parallel()
	serviceName := "nginx-highway-service"
	output := "<h1>Welcome to nginx!</h1>"
	kubeOptions := k8s.NewKubectlOptions("", "", "highway")
	_, getKubeErr := k8s.GetServiceE(t, kubeOptions, serviceName)
	if getKubeErr != nil {
		defer k8s.DeleteNamespace(t, kubeOptions, "argocd")
		fmt.Println("Infrastructure not found. Running Terraform Apply...")
		kubeContext := os.Getenv("KUBE_CONTEXT")
		if kubeContext == "" {
			kubeContext = "minikube"
		}
		terraformOptions := &terraform.Options{
			TerraformDir: "../../terraform",
			Vars: map[string]interface{}{
				"kube_context": kubeContext,
			},
		}
		defer terraform.Destroy(t, terraformOptions)
		terraform.InitAndApply(t, terraformOptions)
		k8s.WaitUntilServiceAvailable(t, kubeOptions, serviceName, 12, 5*time.Second)
	} else {
		fmt.Println("Infrastructure already exists. Skipping Apply and running health checks...")
	}
	argoOptions := k8s.NewKubectlOptions("", "", "argocd")
	k8s.RunKubectl(t, argoOptions, "wait", "--for=condition=available", "deploy/argocd-server", "--timeout=300s")
	podFilter := metav1.ListOptions{LabelSelector: "app=nginx-highway-app"}
	k8s.WaitUntilNumPodsCreated(t, kubeOptions, podFilter, 1, 60, 10*time.Second)
	pods := k8s.ListPods(t, kubeOptions, podFilter)
	k8s.WaitUntilPodAvailable(t, kubeOptions, pods[0].Name, 60, 10*time.Second)
	tunnel := k8s.NewTunnel(kubeOptions, k8s.ResourceTypeService, serviceName, 0, 80)
	defer tunnel.Close()
	tunnel.ForwardPort(t)
	url := fmt.Sprintf("http://%s", tunnel.Endpoint())
	http_helper.HttpGetWithCustomValidation(t, url, nil, func(statusCode int, body string) bool {
		return statusCode == 200 && strings.Contains(body, output)
	})
}
