#!/bin/bash

AUTO_APPROVE=0
STAGE="local"
while [[ $# -gt 0 ]]; do
    case $1 in
        -s=*)
            AUTO_APPROVE="${1#*=}"
            shift
            ;;
        -s)
            AUTO_APPROVE="$2"
            shift 2
            ;;
        --stage=*)
            AUTO_APPROVE="${1#*=}"
            shift
            ;;
        --stage)
            AUTO_APPROVE="$2"
            shift 2
            ;;
        -a=*)
            AUTO_APPROVE="${1#*=}"
            shift
            ;;
        -a)
            AUTO_APPROVE="$2"
            shift 2
            ;;
        --auto-approve=*)
            AUTO_APPROVE="${1#*=}"
            shift
            ;;
        --auto-approve)
            AUTO_APPROVE="$2"
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
if [[ ! -d "./plan" ]]; then
    echo "No plan directory found"
    exit 1
fi

if [[ "$AUTO_APPROVE" == "true" || "$AUTO_APPROVE" == "1" ]]; then
    LAST_PLAN=$(ls ./plan/tf-*.tfplan 2>/dev/null | sort -V | tail -n1)
    
    if [[ -z "$LAST_PLAN" ]]; then
        echo "No .tfplan files found in ./plan"
        exit 1
    fi

    terraform apply "$LAST_PLAN"
    echo "Applied $LAST_PLAN successfully"
else
    terraform apply
    echo "Applied successfully"
fi
elif [[ $STAGE == "local-cd" ]]
terraform apply tfplan
echo "Applied successfully"
fi