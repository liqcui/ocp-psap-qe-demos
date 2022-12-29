#!/bin/bash
echo -e "\e[1;31m####################################################################\e[0m"
echo -e "\e[1;31m##              The NTO on Hypershift Demo Statedi                ##\e[0m"
echo -e "\e[1;31m####################################################################\e[0m"
echo 
echo
echo -e "\e[1;31m###################################################################\e[0m"
echo -e "\e[1;31m##       Execute below command in management OCP clusters        ##\e[0m"
echo -e "\e[1;31m###################################################################\e[0m"
echo
echo
echo -e "\e[1;31m###################################################################\e[0m"
echo -e "\e[1;31m##                       DEMO  CASE                              ##\e[0m"
echo -e "\e[1;31m##          NTO support tuning sysctl that applied to            ##\e[0m"
echo -e "\e[1;31m##       all nodes of nodepool-level settings in hypershift      ##\e[0m"
echo -e "\e[1;31m###################################################################\e[0m"
echo

echo -e "\e[1;32m###################################################################\e[0m"
echo -e "\e[1;32m##         Create configmap for NTO in clusters namespace        ##\e[0m"
echo -e "\e[1;32m###################################################################\e[0m"
echo 
echo -e "\e[1;32m###################################################################\e[0m"
echo -e "\e[1;32m----------------               BEGIN           --------------------\e[0m"
oc get configmap -n clusters |grep hc-nodepool-vmdratio
echo 
if [ $? -eq 0 ];then
	echo -e "\e[1;32mThe Configmap has been created, delete it first, then create new one\e[0m"
	oc delete configmap hc-nodepool-vmdratio -n clusters 
fi
cat <<EOF
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

sleep 8
oc create -f-<<EOF
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
echo -e "\e[1;36moc patch -n clusters nodepool psap-qe-hcluster01-us-east-2a --type merge -p '{"spec":{"tuningConfig":[{"name": "hc-nodepool-vmdratio"}]}}'\e[0m"
oc patch -n clusters nodepool psap-qe-hcluster01-us-east-2a --type merge -p '{"spec":{"tuningConfig":[{"name": "hc-nodepool-vmdratio"}]}}'
echo -e "\e[1;32m###################################################################\e[0m"
echo -e "\e[1;32m##         check if the configmap created and generated          ##\e[0m"
echo -e "\e[1;32m##      in both clusters and clusters-psap-qe-hcluster01         ##\e[0m"
echo -e "\e[1;32m###################################################################\e[0m"
sleep 8
echo -e "\e[1;36moc get configmap -n clusters\e[0m"
echo -e "\e[1;32m###################################################################\e[0m"
oc get configmap -n clusters| grep hc-nodepool-vmdratio
echo 
echo -e "\e[1;36moc get configmap -n clusters-psap-qe-hcluster01 | grep tuned\e[0m"
echo -e "\e[1;32m###################################################################\e[0m"
oc get configmap -n clusters-psap-qe-hcluster01 | grep tuned
echo 
echo -e "\e[1;32m###################################################################\e[0m"
echo -e "\e[1;32m----------------               END             --------------------\e[0m"
sleep 8
echo
echo -e "\e[1;31m###################################################################\e[0m"
echo -e "\e[1;31m##       Execute below command in hosted/guest OCP clusters      ##\e[0m"
echo -e "\e[1;31m###################################################################\e[0m"
echo
echo -e "\e[1;31m###################################################################\e[0m"
echo -e "\e[1;31m##        Check If NTO Tuned and Profile Applied to Nodepool     ##\e[0m"
echo -e "\e[1;31m## The tuning sysctl applied to worker nodes in hosted cluster   ##\e[0m"
echo -e "\e[1;31m###################################################################\e[0m"
echo
sleep 8
echo -e "\e[1;33####################################################################\e[0m"
echo -e "\e[1;33m----------------               BEGIN           --------------------\e[0m"
hypershift create kubeconfig >~/guest.kubeconfig
export KUBECONFIG=~/guest.kubeconfig
oc config use-context clusters-psap-qe-hcluster01
echo -e "\e[1;36moc get nodes\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
oc get nodes
echo 
sleep 8
echo -e "\e[1;36moc get Tuneds -n openshift-cluster-node-tuning-operator\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
oc get Tuneds -n openshift-cluster-node-tuning-operator
echo 
sleep 8
echo -e "\e[1;36moc get Profiles -n openshift-cluster-node-tuning-operator\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
oc get Profiles -n openshift-cluster-node-tuning-operator
echo 
sleep 8
echo -e "\e[1;33mCheck the value of vm.dirty_ratio on worker nodes in hosted cluster\e[0m"
echo  -e "\e[1;36mfor node in `oc get nodes -oname`;do oc debug $node --quiet=true -n openshift-cluster-node-tuning-operator -- chroot /host sysctl vm.dirty_ratio; done\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
for node in `oc get nodes -oname`;do oc debug $node --quiet=true -n openshift-cluster-node-tuning-operator -- chroot /host sysctl vm.dirty_ratio; done
echo -e "\e[1;33m###################################################################\e[0m"
echo -e "\e[1;33m----------------               END             --------------------\e[0m"
echo 
echo -e "\e[1;31m###################################################################\e[0m"
echo -e "\e[1;31m##Rollback sysctl vm.dirty_ratio that changed in hosted clusters ##\e[0m"
echo -e "\e[1;31m###################################################################\e[0m"
echo 
echo 
echo -e "\e[1;31m###################################################################\e[0m"
echo -e "\e[1;31m##       Execute below command in management OCP clusters        ##\e[0m"
echo -e "\e[1;31m###################################################################\e[0m"
echo
echo -e "\e[1;32m###################################################################\e[0m"
echo -e "\e[1;32m----------------               BEGIN           --------------------\e[0m"
export KUBECONFIG=~/.kube/config
echo  -e "\e[1;36moc patch -n clusters nodepool psap-qe-hcluster01-us-east-2a --type merge  -p '{"spec":{"tuningConfig":[]}}'\e[0m"
oc patch -n clusters nodepool psap-qe-hcluster01-us-east-2a --type merge  -p '{"spec":{"tuningConfig":[]}}'
echo -e "\e[1;32m###################################################################\e[0m"
echo -e "\e[1;32m----------------               END            --------------------\e[0m"
echo
echo
sleep 8
echo -e "\e[1;31m###################################################################\e[0m"
echo -e "\e[1;31m##       Execute below command in hosted/guest OCP clusters      ##\e[0m"
echo -e "\e[1;31m###################################################################\e[0m"
echo
echo -e "\e[1;33m###################################################################\e[0m"
echo -e "\e[1;33m##       Check If NTO Tuned and Profile Rollback on NodePool     ##\e[0m"
echo -e "\e[1;33m##    The value of sysctl vm.dirty_ratio rollback to default     ##\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
echo
echo
sleep 8
echo -e "\e[1;33m###################################################################\e[0m"
echo -e "\e[1;33m----------------               BEGIN           --------------------\e[0m"
echo
export KUBECONFIG=~/guest.kubeconfig
oc config use-context clusters-psap-qe-hcluster01
echo -e "\e[1;36moc get nodes\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
oc get nodes
echo 
sleep 8
echo -e "\e[1;36moc get Tuneds -n openshift-cluster-node-tuning-operator\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
oc get Tuneds -n openshift-cluster-node-tuning-operator
echo 
sleep 8
echo -e "\e[1;36moc get Profiles -n openshift-cluster-node-tuning-operator\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
oc get Profiles -n openshift-cluster-node-tuning-operator
echo 
sleep 8
echo -e "\e[1;33mCheck the value of vm.dirty_ratio on worker nodes in hosted cluster\e[0m"
echo  -e "\e[1;36mfor node in `oc get nodes -oname`;do oc debug $node --quiet=true -n openshift-cluster-node-tuning-operator -- chroot /host sysctl vm.dirty_ratio; done\e[0m"
echo -e "\e[1;33m###################################################################\e[0m"
for node in `oc get nodes -oname`;do oc debug $node --quiet=true -n openshift-cluster-node-tuning-operator -- chroot /host sysctl vm.dirty_ratio; done
echo -e "\e[1;33m###################################################################\e[0m"
echo -e "\e[1;33m----------------                END            --------------------\e[0m"
