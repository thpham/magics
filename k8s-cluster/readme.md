
- First create the policies for the workers and master:

```
aws iam create-policy \
  --policy-name k8sMaster \
  --description "Let CDK create ELBs and access S3" \
  --policy-document file://aws/iam/policy-k8s-master.json

aws iam create-policy \
  --policy-name k8sWorker \
  --description "Let CDK create ELBs and access S3" \
  --policy-document file://aws/iam/policy-k8s-worker.json
```

- create the roles:

```
aws iam create-role \
  --role-name k8sMaster \
  --assume-role-policy-document file://aws/iam/assume-role.json

aws iam create-role \
  --role-name k8sWorker \
  --assume-role-policy-document file://aws/iam/assume-role.json
```

- Attach the roles to the policies:

```
aws iam attach-role-policy \
 --role-name k8sMaster \
 --policy-arn arn:aws:iam::YourAccountID:policy/k8sMaster

aws iam attach-role-policy \
 --role-name k8sWorker \
 --policy-arn arn:aws:iam::YourAccountID:policy/k8sWorker
```

- Create the Instance Profiles and link the roles to the profiles:

```
aws iam create-instance-profile --instance-profile-name k8sMaster-Instance-Profile
aws iam create-instance-profile --instance-profile-name k8sWorker-Instance-Profile
aws iam add-role-to-instance-profile --role-name k8sMaster --instance-profile-name k8sMaster-Instance-Profile
aws iam add-role-to-instance-profile --role-name k8sWorker --instance-profile-name k8sWorker-Instance-Profile
```
