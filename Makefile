.PHONY:
scan:
	trufflehog filesystem . --fail
	trufflehog git file://. --only-verified
	checkov -d . --compact
tf-plan-local:
	./bash/tf-plan-local-setup.sh
tf-apply-local-auto:
	./bash/tf-apply-local-setup.sh --auto-approve true
tf-apply-local:
	./bash/tf-apply-local-setup.sh --auto-approve false
tf-local: 
	$(MAKE) tf-plan-local 
	$(MAKE) tf-apply-local-auto
clean:
	cd terraform && terraform destroy && cd ..