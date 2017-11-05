# download and install kubectl for amd64
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

# download and install minikube for amd64
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.23.0/minikube-linux-amd64 && chmod +x minikube && mv minikube /usr/local/bin/

# starting k8s on local vm
minikube start --vm-driver=kvm

# check the running pods
#   shoule be one default pod and some kube-system pods
kubectl get pods --all-namespaces

# get the k8s api token
SECRET_NAME=$(kubectl get secret -n default | grep default | cut -f 1 -d' ')
kubectl get secret $SECRET_NAME -o yaml | grep token | head -n 1 - |  cut -d' ' -f 4 | base64 -d - 

# download the metrics pods
curl -Lo https://raw.githubusercontent.com/MohawkTSDB/mohawk-container/master/mohawk-k8s-with-crt.yaml

# create the pods
kubectl create -f mohawk-k8s-with-crt.yaml

# check the running pods
#   shoule have mohawk and heapster pods
kubectl get pods --all-namespaces

