## Start
follow initial setup on https://catalog.workshops.aws/eks-immersionday/en-US/autoscaling/karpenter
## migrate crd and important cluster component into fargate
## initiate karpenter usec cases
### Use case 1, default provisioner
--- testing 1, default prov, nap, bipacking, ttl, on-demand, consolidation
prov_1
kubectl scale --replicas=1 deployment/proddetail -n workshop
k create deployment web --image nginx --replicas 20 -n web
k scale --replicas=100 deployment/web -n web
### Use case 2, spot & mixed on demand provisioner
prov_2
### Use case 3, cluster consolidation
prov_3
### Use case 4, arm, multi-exclusive provisioner
prov_5
### Use case 5, topology spread
prov_6 -- need edit
### Use case 5, manual and custom mapping/selectors
prov_6 -- need edit
### Use case 5, custom subnet selections
prov_7
