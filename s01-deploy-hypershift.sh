#!/bin/bash
source common-util.sh
clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant redhat openshift
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'The Installation of Hypershift Demo Stated' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
echo
sleep 8

clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant HyperShift CASE
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Create S3 Bucket for Hypershift' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
sleep 8
clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant highlight
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Execute The Following Command in Management Cluster' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
echo
sleep 8


clear 
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
echo
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
print_stdout_withcolor yellow "`formatStdOutString 'Create S3 Bucket for Hypershift Installation, If No bucket, Create It.' 86`" bold
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo

aws s3 ls |grep psap-qe-ocps3bucket
if [ $? -eq 0 ];then
     print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
     show_prompt_text yellow "The bucket has been created ..."
     print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
else
     display_and_run "aws s3api create-bucket --acl public-read --create-bucket-configuration   LocationConstraint=us-east-2 --region=us-east-2 --bucket psap-qe-ocps3bucket"
fi

print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
sleep 8

######Start Hypershift Operator Deployment
clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Deploy Operator
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Deploy hypershift Operator in <hypershift> namespace' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
sleep 8
clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant highlight
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Execute The Following Command in Management Cluster' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
echo
sleep 8

clear 
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
print_stdout_withcolor blue "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
echo
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
print_stdout_withcolor blue "`formatStdOutString 'Begin to deploy hypershift operator, if No operator, deploy it.' 86`" bold
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
echo

display_and_run "export BUCKET_NAME=psap-qe-ocps3bucket"
display_and_run "export CLUSTER_NAME=psap-qe-hcluster01"
display_and_run "export BASE_DOMAIN=qe.devcluster.openshift.com"
display_and_run "export PULL_SECRET=~/pull-secret.json"
display_and_run "export AWS_CREDS=~/.aws/credentials"
display_and_run "export REGION=us-east-2"

oc get pods -n hypershift |grep -i running
if [ $? -eq 0 ];then
     print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
     show_prompt_text blue "The hypershift operator has been successfully deployed ..."
     print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
else
     display_and_run "hypershift install --hypershift-image=quay.io/openshift-psap-qe/hypershift-operator:nto-poc --oidc-storage-provider-s3-bucket-name $BUCKET_NAME --oidc-storage-provider-s3-credentials $AWS_CREDS --oidc-storage-provider-s3-region $REGION"
fi

replicas=`/usr/bin/oc get deployment operator -n hypershift -ojsonpath\="{.status.replicas}"`
AvailableStatus=false
while ! `oc get deployment operator -n hypershift -ojsonpath='{.status.conditions[?(@.type=="Available")].status}'| tr [T,F] [t,f]`
do
     sleep 8
     show_prompt_text blue "The hypershift operator isn't ready, continue to check ... "
done

print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
show_prompt_text green "The hypershift operator is ready"
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`

print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
print_stdout_withcolor blue "`formatStdOutString 'Check hypershift pods status in <hypershift> namespace' 86`"
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`

display_and_run "oc get pods -n hypershift"

print_stdout_withcolor blue "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
sleep 8


clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Control Plane
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo

print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Hosted Cluster Control Plane Deployment' 86`"
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 8



clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Highlight
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Execute the following command in managment cluster' 86`"
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 8



clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
print_stdout_withcolor green "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor green `repeatedCharNTimes "#" 86`
print_stdout_withcolor green "`formatStdOutString 'Deploy hosted cluster control plane into.' 86`"
echo -e "\e[1;32m##                           \e[1;31m<clusters_ns-nodepool_name>                           \e[1;32m##\e[0m"
print_stdout_withcolor green "`formatStdOutString 'namespace, create one Hostedcluster and one nodepool by default' 86`"
print_stdout_withcolor green `repeatedCharNTimes "#" 86`
echo

display_and_run "export CLUSTER_NAME=psap-qe-hcluster01"
display_and_run "export BASE_DOMAIN=qe.devcluster.openshift.com"
display_and_run "export PULL_SECRET=~/pull-secret.json"
display_and_run "export AWS_CREDS=~/.aws/credentials"
display_and_run "export REGION=us-east-2"

RC=1
oc get ns |grep clusters
if [ $? -eq 0 ];then
    oc get nodepool -n clusters | grep psap-qe
    if [ $? -eq 0 ];then
	RC=0
        print_stdout_withcolor green `repeatedCharNTimes "-" 86`
        show_prompt_text green "The Hosted Cluster Control Plane Has Been Created ... ..."
        print_stdout_withcolor green `repeatedCharNTimes "-" 86`
    fi
else
	RC=1
fi

if [ $RC -eq 1 ];then
    display_and_run "hypershift create cluster aws --name $CLUSTER_NAME --node-pool-replicas=2 --base-domain $BASE_DOMAIN --pull-secret $PULL_SECRET --aws-creds $AWS_CREDS --region $REGION --generate-ssh --release-image=quay.io/openshift-release-dev/ocp-release:4.12.0-x86_64"
    print_stdout_withcolor green `repeatedCharNTimes "-" 86`
    show_prompt_text green "It will take 5-10 minutes to complete, waiting for hosted cluster and nodepool be ready"
    print_stdout_withcolor green `repeatedCharNTimes "-" 86`
else
        print_stdout_withcolor green `repeatedCharNTimes "-" 86`
        show_prompt_text green "The Hosted Cluster Control Plane Has Been Created, No Need to Execute the command  ..."
        print_stdout_withcolor green `repeatedCharNTimes "-" 86`
fi

NODEPOOL_STATUS=false
HOSTEDCLUSTER_STATUS=false
sleep 5 
while true
do
    HOSTEDCLUSTER_STATUS=`oc get hostedcluster -n clusters -ojsonpath={..status.version.history[*].state} | tr [A-Z] [a-z]`
    NODEPOOL_STATUS=`oc get nodepool psap-qe-hcluster01-us-east-2a -n clusters -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}'| tr [T,F] [t,f]`
    echo  "The status of hosted cluster is $HOSTEDCLUSTER_STATUS and The ready status of nodepool is $NODEPOOL_STATUS"
    if [[ $NODEPOOL_STATUS == "true" && $HOSTEDCLUSTER_STATUS == "completed" ]];then
        print_stdout_withcolor green `repeatedCharNTimes "-" 86`
        show_prompt_text green "The Hosted Cluster and NodePool is ready"
        print_stdout_withcolor green `repeatedCharNTimes "-" 86`
        break
    fi 
        sleep 15
done
echo
print_stdout_withcolor green "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
sleep 8

clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Verify ControlPlane
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
print_stdout_withcolor blue "`formatStdOutString 'Check If Hosted Cluster Control Plane is Ready' 86`"
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
echo
sleep 8

clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Management Cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
print_stdout_withcolor blue "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
print_stdout_withcolor blue "`formatStdOutString 'Check the POD status for hosted cluster controlplane' 86`"
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
echo
display_and_run "oc get pods -n clusters-psap-qe-hcluster01"
echo
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
print_stdout_withcolor blue "`formatStdOutBeginEndString 'END' 86`"
sleep 8

clear
echo 
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Management Cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo 
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
print_stdout_withcolor blue "`formatStdOutString 'Check If Hosted Cluster Is Ready' 86`"
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`

echo
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
print_stdout_withcolor blue "`formatStdOutBeginEndString 'BEGIN' 86`"
display_and_run "oc get hostedcluster -n clusters"

echo
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
print_stdout_withcolor blue "`formatStdOutString 'Check If The Default NodePool is Ready' 86`"
print_stdout_withcolor blue `repeatedCharNTimes "#" 86`
display_and_run "oc get nodepool -n clusters"
echo
print_stdout_withcolor blue "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
sleep 8

clear
echo 
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Management Cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
print_stdout_withcolor yellow "`formatStdOutString 'Check Worker Node and NTO pods in openshift-cluster-node-tuning-operator' 86`" bold
print_stdout_withcolor yellow "`formatStdOutString 'Those worker nodes and pod belong to hosted cluster,' 86`" bold
print_stdout_withcolor yellow "`formatStdOutString 'rather than management cluster' 86`" bold
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo
print_stdout_withcolor blue `repeatedCharNTimes "-" 86`
print_stdout_withcolor blue "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Switch to Hosted/Guest Cluster"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
echo
display_and_run "hypershift create kubeconfig >~/guest.kubeconfig"
display_and_run "export KUBECONFIG=~/guest.kubeconfig"
display_and_run "oc config use-context clusters-psap-qe-hcluster01"
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant hosted cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
display_and_run "oc get nodes"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text green "No master node in hosted cluster, only worker nodes"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`

display_and_run "oc get ns"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Those namespace is in hosted cluster, rather than management cluster namespace"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
echo 

display_and_run "oc get pods -n openshift-cluster-node-tuning-operator"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "The NTO pods is in hosted cluster, rather than management cluster namespace"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
echo 
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
