cd terraform
mkdir -p ./plan 
LAST_NUM=$(ls ./plan/tf-*.tfplan 2>/dev/null | grep -oE '[0-9]+' | sort -n | tail -1)
NEXT_NUM=$(( ${LAST_NUM:-0} + 1 ))
FILE_ID=$(printf "%03d" $NEXT_NUM)
terraform init 
terrafrom validate
terraform plan -out "./plan/tf-${FILE_ID}.tfplan"
echo "successfully create plan"