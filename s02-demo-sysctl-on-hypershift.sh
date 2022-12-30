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
print_stdout_withcolor red "`formatStdOutString 'NTO support tuning sysctl that applied to' 86`" bold
print_stdout_withcolor red "`formatStdOutString 'all nodes of nodepool-level settings in hypershift' 86`" bold
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
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
print_stdout_withcolor yellow "`formatStdOutString 'Create configmap for NTO in clusters namespace' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo

oc get configmap -n clusters |grep hc-nodepool-vmdratio
if [ $? -eq 0 ];then
        print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
	show_prompt_text yellow "The Configmap has been created, delete it first, then create new one"
        print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
	echo
	oc delete configmap hc-nodepool-vmdratio -n clusters 
fi
cat <<EOF >hc-nodepool-vmdratio-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
 name: hc-nodepool-vmdratio
 namespace: clusters
data:
 tuning: |
   apiVersion: tuned.openshift.io/v1
   kind: Tuned
   metadata:
     name: hc-nodepool-vmdratio
     namespace: openshift-cluster-node-tuning-operator
   spec:
     profile:
     - data: |
         [main]
         summary=Custom OpenShift profile
         include=openshift-node
 
         [sysctl]
         vm.dirty_ratio="55"
       name: hc-nodepool-vmdratio
     recommend:
     - priority: 20
       profile: hc-nodepool-vmdratio
EOF
echo
display_and_run "cat hc-nodepool-vmdratio-configmap.yaml"
display_and_run "oc apply -f hc-nodepool-vmdratio-configmap.yaml"
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
print_stdout_withcolor yellow "`formatStdOutString 'Apply nodepool level sysctl vm.dirty_ratio settings in hosted clusters.' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo
display_and_run "oc patch -n clusters nodepool psap-qe-hcluster01-us-east-2a --type merge -p '{\"spec\":{\"tuningConfig\":[{\"name\": \"hc-nodepool-vmdratio\"}]}}'"
echo 
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
sleep 8

clear
echo 
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Test Verification
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
print_stdout_withcolor yellow "`formatStdOutString 'check if the configmap created and generated' 86`"
print_stdout_withcolor yellow "`formatStdOutString 'in both clusters and clusters-psap-qe-hcluster01' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "#" 86`
echo 
echo
display_and_run "oc get configmap -n clusters| grep hc-nodepool-vmdratio"
display_and_run "oc get configmap -n clusters-psap-qe-hcluster01 | grep tuned"

echo 
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
sleep 8


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
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
print_stdout_withcolor green "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor green `repeatedCharNTimes "#" 86`
print_stdout_withcolor green "`formatStdOutString 'Check If NTO Tuned and Profile Applied to Custom Nodepool' 86`" bold
print_stdout_withcolor green "`formatStdOutString 'The sysctl vm.dirty_ratio="55" applied to the worker nodes in hosted cluster' 86`" bold
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
show_prompt_text yellow "Check the value of sysctl vm.dirty_ratio on worker nodes in hosted cluster"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
display_and_run "for node in \`oc get nodes -oname\`;do oc debug \$node --quiet=true -n  openshift-cluster-node-tuning-operator -- chroot /host sysctl vm.dirty_ratio; done"
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
print_stdout_withcolor red "`formatStdOutString 'Rollback the value of sysctl vm.dirty_ratio to default' 86`" bold
print_stdout_withcolor red "`formatStdOutString 'on worker nodes in hosted cluster' 86`" bold
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
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant hosted cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
print_stdout_withcolor yellow "`formatStdOutBeginEndString 'BEGIN' 86`"
echo
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
show_prompt_text yellow "Switch back to management clusters"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`

display_and_run "export KUBECONFIG=~/.kube/config"
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
display_and_run "oc get nodes"
display_and_run "oc patch -n clusters nodepool psap-qe-hcluster01-us-east-2a --type merge -p '{\"spec\":{\"tuningConfig\":[]}}'"

print_stdout_withcolor yellow "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor yellow `repeatedCharNTimes "-" 86`
sleep 6
clear
echo
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant Rollback Verification
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
print_stdout_withcolor red "`formatStdOutString 'Check If the value of sysctl vm.dirty_ratio rollback to default' 86`" bold
print_stdout_withcolor red "`formatStdOutString 'on worker node in hosted cluster' 86`" bold
print_stdout_withcolor red `repeatedCharNTimes "#" 86`
echo
sleep 8

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
sleep 8

clear
echo
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
figlet -t -f slant management cluster
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
echo
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
show_prompt_text yellow "Check the value of sysctl vm.dirty_ratio on worker nodes in hosted cluster"
print_stdout_withcolor green `repeatedCharNTimes "-" 86`
display_and_run "for node in \`oc get nodes -oname\`;do oc debug \$node --quiet=true -n  openshift-cluster-node-tuning-operator -- chroot /host sysctl vm.dirty_ratio; done"
print_stdout_withcolor green "`formatStdOutBeginEndString 'END' 86`"
print_stdout_withcolor red `repeatedCharNTimes "-" 86`
