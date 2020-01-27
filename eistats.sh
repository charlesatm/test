#!/bin/bash
psc=`ps -ef | grep wso2ei | grep -v grep | wc -l`
inctanceid=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`

EC2_NAME=$(aws ec2 describe-tags --region=ap-southeast-2 --filters "Name=resource-id,Values=$inctanceid" "Name=key,Values=Name" --outp
ut text | cut -f5)

#echo $EC2_NAME

pstat=0

if [ $psc -ge 2 ]
then
pstat=1
fi
#echo $psc $inctanceid

aws cloudwatch put-metric-data --metric-name wso2ei-process-availability --dimensions Instance=$inctanceid,InstanceName=$EC2_NAME --unit Count --namespace "Custom-Metrics" --value $pstat --region=ap-southeast-2
