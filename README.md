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
```
## migrate crd and important cluster component into fargate
```
eksctl create fargateprofile -f fargate.yaml
eksctl get fargateprofile --cluster eksworkshop-eksctl
```
## initiate karpenter use cases
### Use case 1, default provisioner
--- testing 1, default prov, nap, bipacking, ttl, on-demand, consolidation  </br>
prov_1
```
kubectl logs -f deployment/karpenter -c controller -n karpenter
*open in new terminal
kubectl scale --replicas=25 deployment/proddetail -n workshop
kubectl create namespace web
kubectl create deployment web --image nginx --replicas 20 -n web
kubectl scale --replicas=25 deployment/web -n web
kubectl scale --replicas=50 deployment/web -n web
```
observe carpenter controller terminal, kube-ops-view visualizations
### Use case 2, spot & mixed on demand provisioner
`prov_2`
```
kubectl apply -f prov_2.yaml
kubectl scale --replicas=25 deployment/spot -n default
```
### Use case 3, cluster consolidation
`prov_3`
```
kubectl apply -f prov_3.yaml
```
### Use case 4, arm, multi-exclusive provisioner
`prov_5`
```
kubectl apply -f prov_5.yaml
```
### Use case 5, topology spread
`prov_6 -- need edit`
### Use case 5, manual and custom mapping/selectors
`prov_6 -- need edit`
### Use case 5, custom subnet selections
`prov_7`
