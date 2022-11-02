region=$1
eksclustername=$2
iamuserarn=$3
# followed this document
# https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
rm -r ~/.kube

aws eks update-kubeconfig --region $region --name $eksclustername

kubectl apply -f eks-console-full-access.yaml

# This command returned out found
# eksctl get iamidentitymapping --cluster $eksclustername --region=$region

eksctl create iamidentitymapping \
    --cluster $eksclustername \
    --region=$region \
    --arn $iamuserarn \
    --group eks-console-dashboard-full-access-group \
    --no-duplicate-arns

# eksctl delete iamidentitymapping --cluster $eksclustername --region=$region --arn arn:aws:iam::092693892285:user/parisam

# to see the eks resources via aws portal but didn't work as expected
# kubectl apply -f https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml

# curl -o eks-console-full-access.yaml https://s3.us-west-2.amazonaws.com/amazon-eks/docs/eks-console-full-access.yaml

# # This returned the roles
# kubectl get roles -A

kubectl get clusterroles

