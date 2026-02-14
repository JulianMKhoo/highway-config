.PHONY:

scan:
	trufflehog filesystem . --fail
	trufflehog git file://. --only-verified
	checkov -d . --compact --skip-resources-without-violations

tf-plan-local:
	./bash/tf-plan-setup.sh 

tf-plan-local-ci:
	./bash/tf-plan-setup.sh --stage=local-ci

tf-apply-local-auto:
	./bash/tf-apply-setup.sh --auto-approve true

tf-apply-local:
	./bash/tf-apply-setup.sh --auto-approve false

tf-apply-local-cd:
	./bash/tf-apply-setup.sh --stage=local-cd

tf-local: 
	$(MAKE) tf-plan-local
	$(MAKE) tf-apply-local-auto

helm-render:
	helm template nginx-highway charts/nginx-app -f charts/nginx-app/values.yaml 2>&1

clean:
	@echo "=== Step 1: Removing finalizers from all ArgoCD Applications ==="
	-kubectl get applications -n argocd -o name 2>/dev/null | xargs -I {} kubectl patch {} -n argocd --type merge -p '{"metadata":{"finalizers":[]}}' 2>/dev/null
	@echo "=== Step 2: Terraform destroy ==="
	cd terraform && terraform destroy
	@echo "=== Step 3: Cleaning up leftover resources ==="
	-kubectl delete crd -l app.kubernetes.io/part-of=argocd 2>/dev/null
	-kubectl get ns --no-headers -o custom-columns=':metadata.name' 2>/dev/null | grep -vE '^(default|kube-system|kube-public|kube-node-lease)$$' | xargs -r kubectl delete ns 2>/dev/null
	@echo "=== Clean complete ==="