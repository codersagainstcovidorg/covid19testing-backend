#!/bin/bash
# launch fargate task to create DB
environment=$1

VPC_ID=$(aws ec2 describe-vpcs --filter Name=tag:Name,Values="cac-${environment}" --query Vpcs[].VpcId --output text)

SUBNET=$(aws ec2 describe-subnets --filters "Name=tag:Environment,Values=${environment}" "Name=tag:Tier,Values=private" --query Subnets[0].SubnetId --output text)
SG=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --query SecurityGroups[0].GroupId --output text)


aws ecs run-task --cluster "${environment}-ecs" \
  --launch-type "FARGATE" \
  --overrides '{"containerOverrides": [{"name": "backend","command": ["create"], "environment": [{"name": "ENVIRONMENT","value": "'$environment'"}]}]}' \
  --task-definition "${environment}-backend" \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET],securityGroups=[${SG}],assignPublicIp=DISABLED}" \
  --query 'failures[]' \
  --output text