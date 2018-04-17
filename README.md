# vagrant-ubuntu-kube-dev
`minikube` 와 `docker-for-mac` 보다는 조금 더 실제 환경과 유사한 Kubernetes test
환경을 얻기 위해 Vagrant 를 사용하여 ubuntu 16.04 VM 2대 이상을 띄워 k8s test
환경을 셋업.

## 1. VM Up & Provisioning
```
$ vagrant up
```

Vagrantfile 을 수정없이 그대로 사용한다면 각각 master, worker1 이름을 가진 VM 이
2대 생성된다. master VM 의 ip 는 172.18.18.101 로 셋팅된다. (Vagrantfile 참고)

## 2. Initialize cluster on Master
```
$ vagrant ssh matser
master:$ sudo kubeadm init --apiserver-advertise-address 172.18.18.101 --pod-network-cidr 192.168.0.0/16

[init] Using Kubernetes version: v1.10.1
[init] Using Authorization modes: [Node RBAC]
[preflight] Running pre-flight checks.
	[WARNING SystemVerification]: docker version is greater than the most recently validated version. Docker version: 18.03.0-ce. Max validated version: 17.03
	[WARNING FileExisting-crictl]: crictl not found in system path
Suggestion: go get github.com/kubernetes-incubator/cri-tools/cmd/crictl
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.18.18.101]
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated etcd/ca certificate and key.
[certificates] Generated etcd/server certificate and key.
[certificates] etcd/server serving cert is signed for DNS names [localhost] and IPs [127.0.0.1]
[certificates] Generated etcd/peer certificate and key.
[certificates] etcd/peer serving cert is signed for DNS names [master] and IPs [172.18.18.101]
[certificates] Generated etcd/healthcheck-client certificate and key.
[certificates] Generated apiserver-etcd-client certificate and key.
[certificates] Generated sa key and public key.
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
[controlplane] Wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] Wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] Wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] Waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests".
[init] This might take a minute or longer if the control plane images have to be pulled.
[apiclient] All control plane components are healthy after 69.513444 seconds
[uploadconfig] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[markmaster] Will mark node master as master by adding a label and a taint
[markmaster] Master master tainted and labelled with key/value: node-role.kubernetes.io/master=""
[bootstraptoken] Using token: ncq1jt.xljjc410nc1of91l
[bootstraptoken] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: kube-dns
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 172.18.18.101:6443 --token ncq1jt.xljjc410nc1of91l --discovery-token-ca-cert-hash sha256:d925adcd5170e4bd9ed5e161555bd6d18d0cd32a300e124e4e5a6777c0d0a027
```

`/etc/kubernetes/admin.conf` 설정 파일을 통해 원격에서 이 클러스터에 접근 할 수
있다.  `kubectl` 에서 이 설정 파일을 사용하려면 로그에 나온 가이드를 참고해서
`$HOME/.kube/config` 위치에 설정 파일을 복사해두면 된다.

마지막 join 명령어는 그대로 복사해서 worker VM 안에서 사용할 것이다.


## 3. Join Worker node into cluster
```
$ vagrant ssh matser
worker1:$ sudo kubeadm join 172.18.18.101:6443 --token ncq1jt.xljjc410nc1of91l --discovery-token-ca-cert-hash sha256:d925adcd5170e4bd9ed5e161555bd6d18d0cd32a300e124e4e5a6777c0d0a027

[preflight] Running pre-flight checks.
	[WARNING SystemVerification]: docker version is greater than the most recently validated version. Docker version: 18.03.0-ce. Max validated version: 17.03
	[WARNING FileExisting-crictl]: crictl not found in system path
Suggestion: go get github.com/kubernetes-incubator/cri-tools/cmd/crictl
[discovery] Trying to connect to API Server "172.18.18.101:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://172.18.18.101:6443"
[discovery] Requesting info from "https://172.18.18.101:6443" again to validate TLS against the pinned public key
[discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "172.18.18.101:6443"
[discovery] Successfully established connection with API Server "172.18.18.101:6443"

This node has joined the cluster:
* Certificate signing request was sent to master and a response
  was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

## 4. Check
꼭 master VM 에 들어가서 확인할 필요는 없다. 1번 과정에서 나온 `admin.conf`
파일과 `kubectl` 그리고 master VM 에 접근 가능한 네트워크 상에만 있다면
어디서든 접속 할 수 있다.

```
$ vagrant ssh master
master:$ kubectl get node
NAME      STATUS     ROLES     AGE       VERSION
master    NotReady   master    9m        v1.10.1
worker1   NotReady   <none>    1m        v1.10.1

master:$ kubectl get all --all-namespaces
NAMESPACE     NAME                                 READY     STATUS    RESTARTS   AGE
kube-system   pod/etcd-master                      1/1       Running   0          3m
kube-system   pod/kube-apiserver-master            1/1       Running   0          3m
kube-system   pod/kube-controller-manager-master   1/1       Running   0          3m
kube-system   pod/kube-dns-86f4d74b45-p4c6r        0/3       Pending   0          10m
kube-system   pod/kube-proxy-ktrnl                 1/1       Running   0          10m
kube-system   pod/kube-proxy-tl2tl                 1/1       Running   0          3m
kube-system   pod/kube-scheduler-master            1/1       Running   0          3m

NAMESPACE     NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
default       service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP         11m
kube-system   service/kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP   11m

NAMESPACE     NAME                        DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-system   daemonset.apps/kube-proxy   2         2         2         2            2           <none>          11m

NAMESPACE     NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
kube-system   deployment.apps/kube-dns   1         1         1            0           11m

NAMESPACE     NAME                                  DESIRED   CURRENT   READY     AGE
kube-system   replicaset.apps/kube-dns-86f4d74b45   1         1         0         10m
```

가장 먼저 할 일은 pod network 를 설치해주는 것이다. network 또한 모듈화 되어
있어서 원하는 network 를 [여기][pod_network]에서 하나 선택 하여 설치할 수 있다.
가장 앞에 있는 RBAC 를 지원하는 calico 를 선택한다면,
```
master:$ kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

configmap "calico-config" created
daemonset.extensions "calico-etcd" created
service "calico-etcd" created
daemonset.extensions "calico-node" created
deployment.extensions "calico-kube-controllers" created
clusterrolebinding.rbac.authorization.k8s.io "calico-cni-plugin" created
clusterrole.rbac.authorization.k8s.io "calico-cni-plugin" created
serviceaccount "calico-cni-plugin" created
clusterrolebinding.rbac.authorization.k8s.io "calico-kube-controllers" created
clusterrole.rbac.authorization.k8s.io "calico-kube-controllers" created
serviceaccount "calico-kube-controllers" created
```

많은 자원이 설치된다. Pod 은 뭔가 순서에 의해 설치되는 듯하다. 아래 `watch`
명령어를 사용하여 모든 팟이 `Running` 상태가 될때까지 모니터링 하고 있으면
편리하다.

```
master:$ watch kubectl get all --all-namespaces -o wide
```

## 5. Test
모든 팟이 `Running` 상태가 되었다면 애플리케이션을 배포할 준비가 된 것이다.
컨테이너 자신의 `hostname` 을 응답하는 간단한 애플리케이션 서버를 배포해보자.
```
master:$ kubectl run whoami --image=jwilder/whoami
master:$ kubectl get all
NAME                          READY     STATUS    RESTARTS   AGE
pod/whoami-84c96fd974-67bgt   1/1       Running   0          8m

NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/kubernetes      ClusterIP   10.96.0.1      <none>        443/TCP          39m

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/whoami   1         1         1            1           8m

NAME                                DESIRED   CURRENT   READY     AGE
replicaset.apps/whoami-84c96fd974   1         1         1         8m
```

접속이 잘 되는지 확인하기 위해 `service` 를 생성 한 후 접속해보자. 참고로 서버는
`8000`번 port 를 사용한다.
```
matser:$ kubectl expose deploy/whoami --type=NodePort --name=hello-service --port=8000
matser:$ kubectl get svc

NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-service   NodePort    10.99.246.93   <none>        8000:32414/TCP   3m
kubernetes      ClusterIP   10.96.0.1      <none>        443/TCP          41m
```

worker VM 의 private IP 주소는 `172.18.18.102` 이며 HOST OS 에서 접근 가능하다.
http://172.18.18.102:32414 (32414는 랜덤부여됨) 주소를 브라우저로 접근해보자.

```
I'm whoami-84c96fd974-67bgt
```

위와 같이 찍힌다면 성공!

## 6. References

- https://kubernetes.io/docs/setup/independent/install-kubeadm/
- https://hub.docker.com/r/jwilder/whoami/

[pod_network]: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network
