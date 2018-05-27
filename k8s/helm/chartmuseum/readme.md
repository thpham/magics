chartmuseum: 0.5.2 chart 1.3.1

helm install --namespace tools --name chartmuseum -f values.yaml --version 1.3.1 stable/chartmuseum


export POD_NAME=$(kubectl get pods --namespace tools -l "app=chartmuseum" -l "release=chartmuseum" -o jsonpath="{.items[0].metadata.name}")

kubectl --namespace tools port-forward $POD_NAME 8080

