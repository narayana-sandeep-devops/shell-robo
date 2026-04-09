#!/bin.bash

SG_ID="sg-0c53fd79d4d2aa973"
AMI_ID="ami-0220d79f3f480ecf5"



for instance in $@
do
    instance_id = $( aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type "t3.micro" \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text )

        if [ $instance_id == "frontend"]; then
            IP=$(
            aws ec2 describe-instances \
                --instance-ids i-0a639930ecf0ae6c2 \
                --query 'Reservations[].Instances[].PublicIpAddress' \
                --output text
            )
        else
            IP=$(
            aws ec2 describe-instances \
                --instance-ids i-0a639930ecf0ae6c2 \
                --query 'Reservations[].Instances[].PrivateIpAddress' \
                --output text
            )
done





