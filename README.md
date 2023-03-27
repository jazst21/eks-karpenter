## Start
follow initial setup on https://catalog.workshops.aws/eks-immersionday/en-US/autoscaling/karpenter
## install kube-ops-view
```
helm repo add christianknell https://christianknell.github.io/helm-charts
helm repo update
kubectl create namespace kube-ops-view
helm install kube-ops-view --namespace kube-ops-view \
christianknell/kube-ops-view \
--set service.type=LoadBalancer \
--set rbac.create=True
kubectl get all -n kube-ops-view
```
## initiate karpenter use cases
### Use case 1, default provisioner
`prov_0` & `prov_1` as example
```
export CLUSTER_NAME=eksworkshop-eksctl
kubectl logs -f deployment/karpenter -c controller -n karpenter
*open in new terminal
kubectl apply -f prov_0.yaml
kubectl scale --replicas=25 deployment/default
kubectl scale --replicas=50 deployment/default
kubectl scale --replicas=1 deployment/default
kubectl delete -f prov_0.yaml
```
```
kubectl logs -f deployment/karpenter -c controller -n karpenter
*open in new terminal
kubectl apply -f prov_1.yaml
kubectl scale --replicas=25 deployment/default
kubectl scale --replicas=50 deployment/default
kubectl scale --replicas=1 deployment/default
kubectl scale --replicas=25 deployment/proddetail -n workshop
kubectl scale --replicas=50 deployment/proddetail -n workshop
kubectl scale --replicas=1 deployment/proddetail -n workshop
kubectl create namespace web
kubectl create deployment web --image nginx --replicas 20 -n web
kubectl scale --replicas=25 deployment/web -n web
kubectl scale --replicas=50 deployment/web -n web
kubectl delete -f prov_1.yaml
```
observe carpenter controller terminal, kube-ops-view visualizations. how fast karpenter create nodes after pod scaling. and how fast cluster downscale after pod downscale
### Use case 2, spot & mixed on demand provisioner
`prov_2`
```
kubectl apply -f prov_2.yaml
kubectl scale --replicas=25 deployment/spot -n default
kubectl delete -f prov_2.yaml
```
observe carpenter controller terminal, kube-ops-view visualizations
### Use case 3, cluster consolidation
`prov_3`
```
kubectl apply -f prov_3.yaml
kubectl create deployment web --image nginx --replicas 20 
kubectl scale --replicas=50 deployment/web
kubectl scale --replicas=100 deployment/web
kubectl delete deployment web
kubectl delete -f prov_3.yaml
```
observe carpenter controller terminal, kube-ops-view visualizations. observe how the cluster is being consolidated trough bin-pack feature
### Use case 4, arm, multi-exclusive provisioner
`prov_4`
```
kubectl apply -f prov_4.yaml

kubectl delete -f prov_4.yaml
```
observe carpenter controller terminal, kube-ops-view visualizations. observe how the cluster create new arm nodes, with 2 multi exclusive provisioner running
### Use case 5, topology spread
`prov_5`
```
kubectl apply -f prov_5.yaml
```
observe carpenter controller terminal, kube-ops-view visualizations. observe how the pods are running in 3 diff zones
### Use case 6, manual and custom mapping/selectors
`prov_6`
```
kubectl apply -f prov_6.yaml
```
observe carpenter controller terminal, kube-ops-view visualizations. observe how the 1:1 provisioner mapping works
### Use case 7, custom subnet selections
`prov_7`
```
kubectl apply -f prov_7.yaml
```
observe carpenter controller terminal, kube-ops-view visualizations. observe how karpenter schedule pod on specific subnet. useful for cluster that run diff subnet on databases or non-prod workload or semi regulated workload

