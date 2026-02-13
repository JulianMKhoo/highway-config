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
	cd terraform && terraform destroy && cd ..