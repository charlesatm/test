#!/bin/bash
# config vars
region=ap-southeast-2 # aws region which you need to use
metric_name=WSO2EI-HangState # cloudwatch custom matric name
unit=Count # CloudWatch matric unit
namespace=Custom-Metrics # Name space you need to put this matric
ifconfig=`whereis ifconfig | awk '{print $2}'`

instance_ip=`$ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'`
#integrator_path=/mnt/$instance_ip/wso2ei-6.4.0
inctanceid=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
EC2_NAME=$(aws ec2 describe-tags --region=ap-southeast-2 --filters "Name=resource-id,Values=$inctanceid" "Name=key,Values=Name" --output text | cut -f5)
instance_port=9443
timeout=30
server_status=0

curlout=`curl -k -s https://$instance_ip:$instance_port/services/Version -m $timeout`

if [ $? -eq 0 ]
then
        server_status=1
fi


aws cloudwatch put-metric-data --metric-name $metric_name --dimensions Instance=$inctanceid,InstanceName=$EC2_NAME --unit $unit --namespace "$namespace" --value $server_status --region=$region
