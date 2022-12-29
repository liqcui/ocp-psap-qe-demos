#!/bin/bash
clear
echo -e "\e[1;31m###############################################################\e[0m"
echo -e "\e[1;31m##        The Hypershift Deloyment Demo Stated               ##\e[0m"
echo -e "\e[1;31m###############################################################\e[0m"
echo 
echo
sleep 3
clear

echo -e "\e[1;31m###############################################################\e[0m"
echo -e "\e[1;31m##      Execute below command in management OCP clusters     ##\e[0m"
echo -e "\e[1;31m###############################################################\e[0m"
echo
echo
echo
sleep 3
clear
echo -e "\e[1;33m###############################################################\e[0m"
echo -e "\e[1;33m##             Create S3 Bucket for Hypershift               ##\e[0m"
echo -e "\e[1;33m###############################################################\e[0m"
echo 
echo -e "\e[1;33m###############################################################\e[0m"
echo -e "\e[1;33m-------------              BEGIN           --------------------\e[0m"
echo
echo -e "\e[1;36maws s3api create-bucket --acl public-read --create-bucket-configuration   LocationConstraint=us-east-2 --region=us-east-2 --bucket psap-qe-ocps3bucket\e[0m"
echo -e "\e[1;33m###############################################################\e[0m"
aws s3 ls |grep psap-qe-ocps3bucket
if [ $? -eq 0 ];then
	echo -e "\e[1;33mThe bucket has been created ...\e[0m"
else
   aws s3api create-bucket --acl public-read --create-bucket-configuration   LocationConstraint=us-east-2 --region=us-east-2 --bucket psap-qe-ocps3bucket
fi
echo -e "\e[1;33m################################################################\e[0m"
echo -e "\e[1;33m----------------           COMPLETE         --------------------\e[0m"
sleep 8
echo
echo -e "\e[1;34m###############################################################\e[0m"
echo -e "\e[1;34m## Deploy hypershift Operator in <hypershift> namespace      ##\e[0m"
echo -e "\e[1;34m###############################################################\e[0m"
echo 
echo -e "\e[1;34m###############################################################\e[0m"
echo -e "\e[1;34m-------------              BEGIN           --------------------\e[0m"
echo
echo -e "\e[1;36mBUCKET_NAME=psap-qe-ocps3bucket\e[0m"
echo -e "\e[1;36mCLUSTER_NAME=psap-qe-hcluster01\e[0m"
echo -e "\e[1;36mBASE_DOMAIN=qe.devcluster.openshift.com\e[0m"
echo -e "\e[1;36mPULL_SECRET=~/pull-secret.json\e[0m"
echo -e "\e[1;36mAWS_CREDS=~/.aws/credentials\e[0m"
echo -e "\e[1;36mREGION=us-east-2\e[0m"
echo -e "\e[1;36mhypershift install --hypershift-image=quay.io/openshift-psap-qe/hypershift-operator:nto-poc --oidc-storage-provider-s3-bucket-name $BUCKET_NAME --oidc-storage-provider-s3-credentials $AWS_CREDS --oidc-storage-provider-s3-region $REGION\e[0m"
echo -e "\e[1;34m###############################################################\e[0m"
sleep 8
BUCKET_NAME=psap-qe-ocps3bucket
CLUSTER_NAME=psap-qe-hcluster01
BASE_DOMAIN=qe.devcluster.openshift.com
PULL_SECRET=~/pull-secret.json
AWS_CREDS=~/.aws/credentials
REGION=us-east-2
oc get pods -n hypershift |grep -i running
if [ $? -eq 0 ];then
        echo -e "\e[1;34m###############################################################\e[0m"
	echo -e "\e[1;34m##  The hypershift operator has been successfully deployed   ##\e[0m"
        echo -e "\e[1;34m###############################################################\e[0m"
	echo
sleep 8
else
    hypershift install --hypershift-image=quay.io/openshift-psap-qe/hypershift-operator:nto-poc --oidc-storage-provider-s3-bucket-name $BUCKET_NAME --oidc-storage-provider-s3-credentials $AWS_CREDS --oidc-storage-provider-s3-region $REGION 
fi

replicas=`/usr/bin/oc get deployment operator -n hypershift -ojsonpath\="{.status.replicas}"`
AvailableStatus=false
while ! `oc get deployment operator -n hypershift -ojsonpath='{.status.conditions[?(@.type=="Available")].status}'| tr [T,F] [t,f]`
do
  sleep 8
done
echo
echo -e "\e[1;34m###############################################################\e[0m"
echo -e "\e[1;34m##            Check hypershift pods status ...               ##\e[0m"
echo -e "\e[1;34m###############################################################\e[0m"
echo -e "\e[1;36moc get pods -n hypershift\e[0m"
sleep 8
oc get pods -n hypershift
echo -e "\e[1;34m################################################################\e[0m"
echo -e "\e[1;34m----------------           COMPLETE         --------------------\e[0m"
echo
echo 
echo -e "\e[1;32m###############################################################\e[0m"
echo -e "\e[1;32m##            Deploy Hosted Cluster Control Plane            ##\e[0m"
echo -e "\e[1;32m##         In \e[1;31m<clusters_ns-nodepool_name>\e[1;32m namespace          ##\e[0m"
echo -e "\e[1;32m##     Create Hostedcluster and one nodepool by default      ##\e[0m"
echo -e "\e[1;32m###############################################################\e[0m"
echo 
echo -e "\e[1;32m###############################################################\e[0m"
echo -e "\e[1;32m-------------              BEGIN           --------------------\e[0m"
echo
echo -e "\e[1;36mCLUSTER_NAME=psap-qe-hcluster01\e[0m"
echo -e "\e[1;36mBASE_DOMAIN=qe.devcluster.openshift.com\e[0m"
echo -e "\e[1;36mPULL_SECRET=~/pull-secret.json\e[0m"
echo -e "\e[1;36mAWS_CREDS=~/.aws/credentials\e[0m"
echo -e "\e[1;36mREGION=us-east-2\e[0m"

echo -e "\e[1;36mhypershift create cluster aws --name $CLUSTER_NAME --node-pool-replicas=2 --base-domain $BASE_DOMAIN --pull-secret $PULL_SECRET --aws-creds $AWS_CREDS --region $REGION --generate-ssh --release-image=quay.io/openshift-release-dev/ocp-release:4.12.0-rc.6-x86_64\e[0m"
sleep 8
CLUSTER_NAME=psap-qe-hcluster01
BASE_DOMAIN=qe.devcluster.openshift.com
PULL_SECRET=~/pull-secret.json
AWS_CREDS=~/.aws/credentials
REGION=us-east-2

RC=1
oc get ns |grep clusters
if [ $? -eq 0 ];then
    oc get nodepool -n clusters | grep psap-qe
    if [ $? -eq 0 ];then
	RC=0
        echo -e "\e[1;32mThe Hosted Cluster Control Plane Has Been Created ...\e[0m"
    fi
else
	RC=1
fi

if [ $RC -eq 1 ];then
    hypershift create cluster aws --name $CLUSTER_NAME --node-pool-replicas=2 --base-domain $BASE_DOMAIN --pull-secret $PULL_SECRET --aws-creds $AWS_CREDS --region $REGION --generate-ssh --release-image=quay.io/openshift-release-dev/ocp-release:4.12.0-rc.6-x86_64
else
        echo -e "\e[1;32mThe Hosted Cluster Control Plane Has Been Created, No Need to Execute the command ...\e[0m"
fi

NODEPOOL_STATUS=false
HOSTEDCLUSTER_STATUS=false
sleep 20 
while true
do
    HOSTEDCLUSTER_STATUS=`oc get hostedcluster -n clusters -ojsonpath={..status.version.history[*].state} | tr [A-Z] [a-z]`
    NODEPOOL_STATUS=`oc get nodepool psap-qe-hcluster01-us-east-2a -n clusters -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}'| tr [T,F] [t,f]`
    echo HOSTEDCLUSTER_STATUS is $HOSTEDCLUSTER_STATUS NODEPOOL_STATUS is $NODEPOOL_STATUS
    if [[ $NODEPOOL_STATUS == "true" && $HOSTEDCLUSTER_STATUS == "completed" ]];then
       echo -e "\e[1;32mThe Hosted Cluster and NodePool is ready...\e[0m"
       break
    fi 
        sleep 5
done
sleep 8
echo -e "\e[1;36moc get pods -n clusters-psap-qe-hcluster01\e[0m"
oc get pods -n clusters-psap-qe-hcluster01
echo
echo
echo -e "\e[1;32m###############################################################\e[0m"
echo -e "\e[1;32m##      Check If Hosted Cluster Control Plane is Ready       ##\e[0m"
echo -e "\e[1;32m##     Create hostedcluster and one nodepool by default      ##\e[0m"
echo -e "\e[1;32m###############################################################\e[0m"
echo -e "\e[1;36moc get nodepool -n clusters\e[0m"
oc get nodepool -n clusters
echo 
sleep 8
echo -e  "\e[1;36moc get hostedcluster -n clusters\e[0m"
oc get hostedcluster -n clusters
echo -e "\e[1;32m################################################################\e[0m"
echo -e "\e[1;32m----------------           COMPLETE         --------------------\e[0m"
