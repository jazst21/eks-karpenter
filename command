helm repo add christianknell https://christianknell.github.io/helm-charts
helm repo update
kubectl create namespace kube-ops-view
helm install kube-ops-view --namespace kube-ops-view \
christianknell/kube-ops-view \
--set service.type=LoadBalancer \
--set rbac.create=True
---
eks-node-viewer
kubectl logs -f deployment/karpenter -c controller -n karpenter
---
eksctl create fargateprofile -f fargate.yaml

---
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json
aws iam create-policy \
   --policy-name AWSLoadBalancerControllerIAMPolicy \
   --policy-document file://iam_policy.json
eksctl create iamserviceaccount \
  --cluster=eksworkshop-eksctl \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
eksctl get iamserviceaccount --cluster eksworkshop-eksctl --name aws-load-balancer-controller --namespace kube-system
---
kubectl scale --replicas=50 deployment/prodcatalog -n workshop 
kubectl get deployments.apps prodcatalog -n workshop
eksctl create fargateprofile --namespace kube-ops-view --cluster eksworkshop-eksctl --name fargate-default
---
