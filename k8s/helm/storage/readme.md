
helm repo add rook-alpha https://charts.rook.io/alpha
helm repo update

helm install --namespace rook-system --name rook rook-alpha/rook --set rbacEnable=false  --set agent.flexVolumeDirPath=/var/lib/kubelet/volumeplugins

kubectl create -f rook-cluster.yaml

kubectl create -f rook-storageclass.yaml