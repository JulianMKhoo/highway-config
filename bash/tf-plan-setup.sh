#!/bin/bash 
STAGE="local"

while [[ $# -gt 0 ]]; do
    case $1 in
        -s=*)
            STAGE="${1#*=}"
            shift
            ;;
        -s)
            STAGE="$2"
            shift 2
            ;;
        --stage=*)
            STAGE="${1#*=}"
            shift
            ;;
        --stage)
            STAGE="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

cd terraform || exit 1

if [[ $STAGE == "local" ]]; then
mkdir -p ./plan 
LAST_NUM=$(ls ./plan/tf-*.tfplan 2>/dev/null | grep -oE '[0-9]+' | sort -n | tail -1)
NEXT_NUM=$(( ${LAST_NUM:-0} + 1 ))
FILE_ID=$(printf "%03d" $NEXT_NUM)
fi

terraform init 
terraform fmt
terraform validate

if [[ $STAGE == "local" ]]; then
terraform plan -out "./plan/tf-${FILE_ID}.tfplan"
elif [[ $STAGE == "local-ci" ]]; then
terraform plan -no-color -out tfplan
fi

echo "successfully create plan"