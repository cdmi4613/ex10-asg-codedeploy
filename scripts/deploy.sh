#!/bin/bash

set -e

REGION="ap-northeast-1"
REPOSITORY="std01-ex10-nginx"

ACCOUNT_ID=$(aws sts get-caller-identity \
  --query Account \
  --output text)

ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE="${ECR_REGISTRY}/${REPOSITORY}:latest"

aws ecr get-login-password \
  --region "${REGION}" \
  | docker login \
      --username AWS \
      --password-stdin "${ECR_REGISTRY}"

docker pull "${IMAGE}"

docker stop ex10-nginx || true
docker rm ex10-nginx || true

docker run -d \
  --name ex10-nginx \
  --restart always \
  -p 80:80 \
  "${IMAGE}"