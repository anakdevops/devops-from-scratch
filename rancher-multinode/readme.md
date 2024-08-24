

```
instance_internal_ips = [
  "10.0.0.2",
  "10.0.0.3",
]
instance_ips = [
  "34.45.189.254",
  "104.155.187.17",
]
```

# Single Node | RKE v1.6.1 | Kubernetes v1.29.7

```
ssh -i rancher-multinode/rancher-key.pem rancher@34.45.189.254
```


```
pastikan ssh ke semua server
sudo su
cat /home/serverdevops/cluster.yml
su serverdevops
cat /home/serverdevops/.ssh/id_rsa.pub
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCewf04aXUpEdSrIzv7HzWBSUYFtDZzj4tL6QiDV4fWUjzO8D1NCkxbejkBMlEfPH5jyNxoilvr8HCKMhRDJ23H6flgw8CzcKggFZZSIuVCFKvx0XrLTPnVWH/mMd5g31XrbaT+UVMsz4NA3KsLQdscGu2faafBDR2RnACVBPrj4Jgr7lyddNfBqFIKk0ltjKeJaJSCT/2WxzymrUoHGRWQLicXk6Musg9E63+sZTCHAgkAf1EupPc9XUIwTKOG0Uzm5POmajPM2N5Bvwv8/1NH45jg3+ERG5qav09ar+1TYrcTmpfa9AnIndQ/U5wJ08y1adN1zS+Q86a7ltf800Tl ansible-generated on rancher-node-1" >> ~/.ssh/authorized_keys
ssh serverdevops@10.0.0.2
```

```
cd /home/serverdevops/
nano cluster.yml
rke up --config cluster.yml
INFO[0176] Finished building Kubernetes cluster successfully
export KUBECONFIG=$HOME/kube_config_cluster.yml
kubectl get nodes
```

```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.13.2
helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=rancher.anakdevops.local
helm list --namespace cattle-system
kubectl -n cattle-system get deploy rancher
kubectl scale --replicas=1 deployment rancher -n cattle-system
kubectl -n cattle-system get deploy rancher -w
```


# Add Node

```
ssh -i rancher-multinode/rancher-key.pem rancher@34.45.189.254
su serverdevops
cat /home/serverdevops/.ssh/id_rsa.pub
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsClf34mY4J+6MP0ncMUlA2qDwZMCIoIDwFZc367e/o7Asct/5dr5e9cXoTswYNgiWp79ELw8m4/FkgM+kNKerp8Sj5DoohdSySfF06EnDHtF2W4/F8QkoMhXr2MXoVZAa2jm59iUHE19/4uX7iw7Wl6WWQNPBTqc84ZZPLPJhbNbb1kPcrXA/qH6jcaszyDI1jErXbpQbAuvJ+e7kgpxKDqdH4Y9gBuRH0H25sS09pN4UCpKe8EUgKPRlm/6WAT2eS42IoCqn+oIosWXTsD0poQTlEx3k4AjbfVsz41xMjjyenToo64cXAu+OBe2Do/UvRS9ND7IZntmMpS6fY4Mb ansible-generated on rancher-node-1" >> ~/.ssh/authorized_keys
ssh serverdevops@10.0.0.2
ssh serverdevops@10.0.0.3
rke config --list-version --all #cek kubernetes version
cd /home/serverdevops/
nano cluster.yml
rke up --config cluster.yml #Add IP Node
```