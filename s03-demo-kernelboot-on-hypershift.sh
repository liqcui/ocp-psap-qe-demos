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
print_stdout_withcolor red "`formatStdOutString 'The NTO on Hypershift Demo Stated' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
echo
sleep 8

clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant NTO DEMO CASE
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString ' NTO Applying tuning which requires kernel boot parameters' 86`" bold
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
print_stdout_withcolor yellow "`formatStdOutString 'Create custom nodepool hugepages-nodepool for hosted clusters' 86`" bold
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo
display_and_run "export NODEPOOL_NAME=hugepages-nodepool"
display_and_run "export INSTANCE_TYPE=m5.2xlarge"
display_and_run "export NODEPOOL_REPLICAS=1"
display_and_run "export CLUSTER_NAME=psap-qe-hcluster01"
display_and_run "hypershift create nodepool aws \
	 --cluster-name $CLUSTER_NAME \
	 --name $NODEPOOL_NAME \
	 --node-count $NODEPOOL_REPLICAS \
	 --instance-type $INSTANCE_TYPE \
	 --render > hugepages-nodepool.yaml"

display_and_run "sed -i 's/upgradeType: Replace/upgradeType: InPlace/' hugepages-nodepool.yaml"

oc get nodepool -n clusters | grep hugepages-nodepool
if [ $? -eq 0 ];then
     print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
     show_prompt_text yellow "The Nodepool hugepages-nodepool has been created"
     print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
else
     display_and_run "oc apply -f hugepages-nodepool.yaml"
fi


print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Checking nodepool status, waiting for new custom nodepool be ready"
show_prompt_text yellow "Usually new custom nodepool will take 5-10 minutes to complete"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`

NODEPOOL_READY_STATUS=false
while true
do
    NODEPOOL_READY_STATUS=`oc get nodepool hugepages-nodepool -n clusters -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}'| tr [T,F] [t,f]`
    echo  "The reday status of nodepool is $NODEPOOL_READY_STATUS"
    if [[ $NODEPOOL_READY_STATUS == "true" ]];then
       show_prompt_text green "The custom nodepool hugepages-nodepool is ready"
       break
    fi
    sleep 5
done
echo 
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
sleep 5



clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'BEGIN' 86`"
echo 
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
print_stdout_withcolor yellow "`formatStdOutString 'Create configmap for NTO in clusters namespace' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo
oc get configmap -n clusters |grep tuned-hugepages
if [ $? -eq 0 ];then
        print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
	show_prompt_text yellow "The Configmap has been created, delete it first, then create new one"
        print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
	echo
	oc delete configmap tuned-hugepages -n clusters 
fi
cat <<EOF >tuned-hugepages-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: tuned-hugepages
 namespace: clusters
data:
 tuning: |
   apiVersion: tuned.openshift.io/v1
   kind: Tuned
   metadata:
     name: hugepages
     namespace: openshift-cluster-node-tuning-operator
   spec:
     profile:
     - data: |
         [main]
         summary=Boot time configuration for hugepages
         include=openshift-node
         [bootloader]
         cmdline_openshift_node_hugepages=hugepagesz=2M hugepages=50
       name: openshift-node-hugepages
     recommend:
     - priority: 20
       profile: openshift-node-hugepages
EOF
echo
display_and_run "cat tuned-hugepages-configmap.yaml"
display_and_run "oc apply -f tuned-hugepages-configmap.yaml"
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
print_stdout_withcolor yellow "`formatStdOutString 'Apply nodepool level hugepages kernel bool settings in hosted clusters.' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo
display_and_run "oc patch -n clusters nodepool hugepages-nodepool --type merge -p '{\"spec\":{\"tuningConfig\":[{\"name\": \"tuned-hugepages\"}]}}'"

print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "It will take 3-5 minutes to reboot, waiting for the status of custom nodepool be ready"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`

NODEPOOL_READY_STATUS="false"
NODEPOOL_UPDATE_STATUS="true"
while true
do
    sleep 10
    NODEPOOL_READY_STATUS=`oc get nodepool hugepages-nodepool -n clusters -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}'| tr [T,F] [t,f]`
    NODEPOOL_UPDATE_STATUS=`oc get nodepool hugepages-nodepool -n clusters -ojsonpath='{.status.conditions[?(@.type=="UpdatingConfig")].status}'| tr [T,F] [t,f]`
    echo "The reday status of nodepool is $NODEPOOL_READY_STATUS and the update status of nodepool is '$NODEPOOL_UPDATE_STATUS'"
    if [[ $NODEPOOL_UPDATE_STATUS != "true" && $NODEPOOL_READY_STATUS == "true" ]];then
       show_prompt_text green "The custom nodepool hugepages-nodepool is ready"
       break
    fi
done
echo 
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
sleep 5


clear
echo 
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Test Verification
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo

print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Verify NTO Cconfigumap and hugepagesz settings in /etc/cmdcline' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 6

clear 
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant highlight
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Execute The Following Command In Management Cluster' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 6

clear
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
print_stdout_withcolor green "`formatStdOutBeginEndString 'BEGIN' 86`"
echo 
print_stdout_withcolor green `repeatedCharNTimes "#" 86`
print_stdout_withcolor green "`formatStdOutString 'check if the configmap created and generated' 86`"
print_stdout_withcolor green "`formatStdOutString 'in both clusters and clusters-psap-qe-hcluster01' 86`"
print_stdout_withcolor green `repeatedCharNTimes "#" 86`

display_and_run "oc get configmap -n clusters| grep tuned-hugepages"
display_and_run "oc get configmap -n clusters-psap-qe-hcluster01 | grep tuned"
echo
print_stdout_withcolor green "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
echo
sleep 6


clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant highlight
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Execute The Following Command In Hosted/Guest Cluster' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
echo
sleep 6

clear
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
print_stdout_withcolor green "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor green `repeatedCharNTimes "#" 86`
print_stdout_withcolor green "`formatStdOutString 'Check If NTO Tuned and Profile Applied to Custom Nodepool' 86`" bold
print_stdout_withcolor green "`formatStdOutString 'The hugepagesz applied to /etc/cmdline on worker nodes in hosted cluster' 86`" bold
print_stdout_withcolor green `repeatedCharNTimes "#" 86`
echo
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Switch to Hosted/Guest Cluster"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
echo
display_and_run "hypershift create kubeconfig >~/guest.kubeconfig"
display_and_run "export KUBECONFIG=~/guest.kubeconfig"
display_and_run "oc config use-context clusters-psap-qe-hcluster01"
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant hosted cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
display_and_run "oc get nodes"
display_and_run "oc get Tuneds -n openshift-cluster-node-tuning-operator"
display_and_run "oc get Profiles -n openshift-cluster-node-tuning-operator"
echo 

print_stdout_withcolor green `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Check the value of hugepage setting in /proc/cmdline on worker nodes in hosted cluster"
show_prompt_text yellow "Only worker nodes of clustom nodepool take effective, other worker nodes don't apply NTO profile"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
display_and_run "for node in \`oc get nodes -oname\`;do oc debug \$node --quiet=true -n  openshift-cluster-node-tuning-operator -- chroot /host cat /proc/cmdline ; done"
echo
print_stdout_withcolor green "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
echo
sleep 5

clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Rollback Test
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Rollback hugepages settings in /proc/cmdline on worker nodes in hosted cluster' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 5

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
sleep 6

clear 
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Switch back to management clusters"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`

display_and_run "export KUBECONFIG=~/.kube/config"
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
display_and_run "oc get nodes"
display_and_run "oc patch -n clusters nodepool hugepages-nodepool --type merge -p '{\"spec\":{\"tuningConfig\":[]}}'"

print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "It will take 3-5 minutes to reboot nodes, waiting for the status of custom nodepool be ready"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`

NODEPOOL_READY_STATUS="false"
NODEPOOL_UPDATE_STATUS="true"
while true
do
    sleep 10
    NODEPOOL_READY_STATUS=`oc get nodepool hugepages-nodepool -n clusters -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}'| tr [T,F] [t,f]`
    NODEPOOL_UPDATE_STATUS=`oc get nodepool hugepages-nodepool -n clusters -ojsonpath='{.status.conditions[?(@.type=="UpdatingConfig")].status}'| tr [T,F] [t,f]`
    echo "nodepool reday status is $NODEPOOL_READY_STATUS and nodepool update status is '$NODEPOOL_UPDATE_STATUS'"
    #Or NODEPOOL_UPDATE_STATUS=
    #NODEPOOL_READY_STATUS=true
    #if [[ (! $NODEPOOL_UPDATE_STATUS)  && $NODEPOOL_READY_STATUS ]];then
    if [[ $NODEPOOL_READY_STATUS == "true" && $NODEPOOL_UPDATE_STATUS != "true" ]];then
       show_prompt_text green "The custom nodepool hugepages-nodepool is ready"
       break
    fi
done
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
clear
echo
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Rollback Verification
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Check If hugepagesz rollback from kernel boot' 86`" bold
print_stdout_withcolor red "`formatStdOutString 'It should remove from /etc/cmdline in custom nodepool' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 6


clear
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant highlight
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Execute The Following Command In Hosted/Guest Cluster' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 6

clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
print_stdout_withcolor green "`formatStdOutBeginEndString 'BEGIN' 86`"


print_stdout_withcolor green `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Switch to Hosted/Guest Cluster"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
echo
display_and_run "hypershift create kubeconfig >~/guest.kubeconfig"
display_and_run "export KUBECONFIG=~/guest.kubeconfig"
display_and_run "oc config use-context clusters-psap-qe-hcluster01"
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant hosted cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
display_and_run "oc get nodes"
display_and_run "oc get Tuneds -n openshift-cluster-node-tuning-operator"
display_and_run "oc get Profiles -n openshift-cluster-node-tuning-operator"
echo 

print_stdout_withcolor green `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Check the value of hugepage setting in  /proc/cmdline on worker nodes in hosted cluster"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
display_and_run "for node in \`oc get nodes -oname\`;do oc debug \$node --quiet=true -n  openshift-cluster-node-tuning-operator -- chroot /host cat /proc/cmdline; done"
echo
print_stdout_withcolor green "`formatStdOutBeginEndString 'END' 86`"
