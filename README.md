## Start
follow initial setup on https://catalog.workshops.aws/eks-immersionday/en-US/autoscaling/karpenter
## optional: migrate crd and important cluster component into fargate
```
eksctl create fargateprofile -f fargate.yaml
eksctl get fargateprofile --cluster eksworkshop-eksctl
```
## install kube-ops-view with aws load balancer controller (NLB)
```
helm repo add christianknell https://christianknell.github.io/helm-charts
helm repo update
kubectl create namespace kube-ops-view
helm install kube-ops-view --namespace kube-ops-view \
christianknell/kube-ops-view \
--set service.type=LoadBalancer \
--set rbac.create=True
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json
aws iam create-policy \
   --policy-name AWSLoadBalancerControllerIAMPolicy \
   --policy-document file://iam_policy.json
eksctl create iamserviceaccount \
  --cluster=eksworkshop-eksctl \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::563418766479:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
eksctl get iamserviceaccount --cluster eksworkshop-eksctl --name aws-load-balancer-controller --namespace kube-system
helm repo add eks https://aws.github.io/eks-charts
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=eksworkshop-eksctl \
    --set serviceAccount.create=false \
    --set region=us-east-1 \
    --set vpcId=$(aws ec2 describe-vpcs | jq -r '.Vpcs[0]|.VpcId') \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kube-ops-view
  namespace: kube-ops-view
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: external
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
spec:
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
  type: LoadBalancer
  selector:
    app.kubernetes.io/instance: kube-ops-view
    app.kubernetes.io/name: kube-ops-view
EOF
```
## initiate karpenter use cases
### Use case 1, default provisioner
`prov_0` & `prov_1` as example
```
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

