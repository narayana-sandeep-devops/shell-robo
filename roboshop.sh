#!/bin.bash

SG_ID="sg-0c53fd79d4d2aa973"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z02709693P5LDKOA75JSO"
DOMAIN_NAME="sandeepinfo.online"
for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type "t3.micro" \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text )

        if [ $instance == "frontend" ]; then
            IP=$(
            aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query 'Reservations[].Instances[].PublicIpAddress' \
                --output text
            )            
        else
            IP=$(
            aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query 'Reservations[].Instances[].PrivateIpAddress' \
                --output text
            )
            RECORD_NAME="$instance.$DOMAIN_NAME" #ex:mongo
        fi
        echo "IP Address: $IP"

        aws route53 list-resource-record-sets \
        --hosted-zone-id <YOUR_HOSTED_ZONE_ID> \
        --change-batch '
            {
                "Comment": "Optional comment",
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": "'$RECORD_NAME'",
                            "Type": "A",
                            "TTL": 1,
                            "ResourceRecords": [
                                { "Value": "$IP" }
                            ]
                        }
                    }
                ]
            }
            echo "Record updated for isntance: $instance"
done


