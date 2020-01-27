#!/bin/bash

# config vars
region=ap-southeast-2 # aws region which you need to use
metric_name=WSO2EI-Heap-Memory-Utils # cloudwatch custom matric name
unit=Percent # CloudWatch matric unitnamespace=Custom-Matrics # Name space you need to put this matric
ifconfig=`whereis ifconfig | awk '{print $2}'`
namespace=Custom-Metrics

instance_ip=`$ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'`
integrator_path=/opt/$instance_ip/wso2ei-6.4.0
inctanceid=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
EC2_NAME=$(aws ec2 describe-tags --region=ap-southeast-2 --filters "Name=resource-id,Values=$inctanceid" "Name=key,Values=Name" --output text | cut -f5)

echo instance_ip : $instance_ip >> /var/log/custommatic.log

Xmx=`grep -oP Xmx[0-9]+ $integrator_path/bin/integrator.sh | awk -Fx '{print $2}'`

pid=`cat $integrator_path/wso2carbon.pid`
echo pid: $pid >> /var/log/custommatic.log
used_heap=`/usr/java/jdk1.8.0/bin/jstat -gc $pid | tail -1 | awk '{split($0,mem," "); used=(mem[3]+mem[4]+mem[6]+mem[8])/1024; print used}'`

echo Max Heap Memory Allocation : $Xmx >> /var/log/custommatic.log
echo Heap Memory Utilization : $used_heap >> /var/log/custommatic.log
heap_util_precent=`printf "%.2f\n" $(echo -e "scale=2\n(($used_heap/$Xmx)*100)"|bc)`

echo Heap Memory Utilization\(\%\) : $heap_util_precent\%
echo -e Heap Memory Utilization\(\%\) : $heap_util_precent\% >> /var/log/custommatic.log

aws cloudwatch put-metric-data --metric-name $metric_name --dimensions Instance=$inctanceid,InstanceName=$EC2_NAME --unit $unit --namespace "$namespace" --value $heap_util_precent --region=$region
