openebs: 0.5.4 chart 0.5.4

---

kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
kubectl -n kube-system patch deploy/tiller-deploy -p '{"spec": {"template": {"spec": {"serviceAccountName": "tiller"}}}}'

helm install -f values.yaml stable/openebs --name openebs --namespace openebs  --version 0.5.4

kubectl apply -f openebs-operator.yaml
kubectl apply -f openebs-storageclasses.yaml


kubectl apply -f percona-pvc.yaml
kubectl apply -f percona-mysql-pod.yaml
