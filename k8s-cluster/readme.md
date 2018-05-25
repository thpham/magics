
# Kubernetes

## requirements:

  - use the sandboxed dev environment (see the main readme)

## local provisioning with virtualbox

  - deploy the cluster: `make deploy`

  - destroy the cluster: `nixops destroy -d k8s && nixops delete -d k8s && rm .created`

## AWS cloud provisioning

  - deploy the cluster: `make deploy-ec2`

  - destroy the cluster: `nixops destroy -d k8s && nixops delete -d k8s && rm .ec2-created`

## Configure kubectl access

After the provisioning, you need to ssh in a master node and edit the ClusterRoleBinding to allow your admin user.

`kubectl edit clusterrolebinding cluster-admin` 

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  creationTimestamp: 2018-05-25T08:32:09Z
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: cluster-admin
  resourceVersion: "84"
  selfLink: /apis/rbac.authorization.k8s.io/v1/clusterrolebindings/cluster-admin
  uid: 1d312aa9-5ff6-11e8-b6bc-08002777c2bf
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:masters
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: admin
```

Then update `kubeconfig.yaml` with the right hostname/ip of kube-apiserver (master)

### Requirements

use [awscli](https://aws.amazon.com/cli/) to create instance profiles and rules to allow kube-apiserver to interact with AWS API (e.g.: to attach PV to ec2 instances or create ELB ...)

- $ `aws configure`: to configure your AWS credentials.
- These NixOps deployments use your `default` aws profile (defined in ~/.aws/credetials).
  If you have multiple profiles, you can override it as runtime argument (`--set  aws-profile=my_other_profile`).
- modify `machines.json` to add security groups and subnetIds that fit your actual VPC configurations. 

- First create the policies for the workers and master:

```
$ aws iam create-policy \
  --policy-name k8sMaster \
  --description "Let your master create ELBs and access S3" \
  --policy-document file://aws/iam/policy-k8s-master.json

$ aws iam create-policy \
  --policy-name k8sWorker \
  --description "Let your worker create/attach EBS volumes and access S3" \
  --policy-document file://aws/iam/policy-k8s-worker.json
```

- create the roles:

```
$ aws iam create-role \
  --role-name k8sMaster \
  --assume-role-policy-document file://aws/iam/assume-role.json

$ aws iam create-role \
  --role-name k8sWorker \
  --assume-role-policy-document file://aws/iam/assume-role.json
```

- Attach the roles to the policies:

  replace `YourAccountID`.

```
$ aws iam attach-role-policy \
 --role-name k8sMaster \
 --policy-arn arn:aws:iam::YourAccountID:policy/k8sMaster

$ aws iam attach-role-policy \
 --role-name k8sWorker \
 --policy-arn arn:aws:iam::YourAccountID:policy/k8sWorker
```

- Create the Instance Profiles and link the roles to the profiles:

```
$ aws iam create-instance-profile --instance-profile-name k8sMaster-Instance-Profile

$ aws iam create-instance-profile --instance-profile-name k8sWorker-Instance-Profile

$ aws iam add-role-to-instance-profile --role-name k8sMaster --instance-profile-name k8sMaster-Instance-Profile

$ aws iam add-role-to-instance-profile --role-name k8sWorker --instance-profile-name k8sWorker-Instance-Profile
```


# TODO:

 - fix: flannel subnet problem, to avoid doing `ip route add 169.254.169.254/32 dev eth0` on each hosts after deployment.
 - create terraform plan to create AWS VPC, subnets, security groups.
 - use the terraform output to fill `machines.json`
 - create a third plan to deploy kubernetes to existing NixOS machines via `deployment.targetHost`
 - ...
