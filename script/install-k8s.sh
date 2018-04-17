sudo apt install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> kubernetes.list.tmp
sudo mv kubernetes.list.tmp /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt install -y kubeadm=1.10.1-00 kubelet=1.10.1-00 kubectl=1.10.1-00
