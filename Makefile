tf-plan: 
	./bash/tf-plan-setup.sh
tf-apply:
	./bash/tf-apply-setup.sh --auto-approve true
tf-apply-auto:
	./bash/tf-apply-setup.sh --auto-approve false
tf: 
	make tf-plan 
	make tf-apply