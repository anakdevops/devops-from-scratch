```
instance_internal_ips = [
  "10.0.0.2",
  "10.0.0.3",
]
instance_ips = [
  "34.45.189.254",
  "104.155.187.17",
]
ssh -i rancher-multinode/rancher-key.pem rancher@34.45.189.254
ssh -i rancher-multinode/rancher-key.pem rancher@104.155.187.17
```


```
pastikan ssh ke semua server
sudo su
cat /home/serverdevops/cluster.yml
```


```
su serverdevops
cat /home/serverdevops/.ssh/id_rsa.pub
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsClf34mY4J+6MP0ncMUlA2qDwZMCIoIDwFZc367e/o7Asct/5dr5e9cXoTswYNgiWp79ELw8m4/FkgM+kNKerp8Sj5DoohdSySfF06EnDHtF2W4/F8QkoMhXr2MXoVZAa2jm59iUHE19/4uX7iw7Wl6WWQNPBTqc84ZZPLPJhbNbb1kPcrXA/qH6jcaszyDI1jErXbpQbAuvJ+e7kgpxKDqdH4Y9gBuRH0H25sS09pN4UCpKe8EUgKPRlm/6WAT2eS42IoCqn+oIosWXTsD0poQTlEx3k4AjbfVsz41xMjjyenToo64cXAu+OBe2Do/UvRS9ND7IZntmMpS6fY4Mb ansible-generated on rancher-node-1" >> ~/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCOrFmFlzQp4bbaTok9CMafB6iMVX71Mv11tsL2F/1GsW0SW4MAMi0SiSnDdkLHbh0RI0pXc+w+3xWTJZNuXpdEIPUrYFWikU+lBrLVnxPoD9Q8SQYCaMghEgrxlktIQhYoQjaZvNDxNNSZoIvCFlEat23Aksh3mLlcAOaDzhjlld1x0BzHu5XEIzve9dEWFhkD4qTOfPu+3FRNyEO10ls21WZQR/6Cidur+Hnx9YW+oUIlaq9GSdg02yfrkOVbjuAjcABY6SmU+/3axGSOycEEXmdW/68ktqKY2LY35V5CE+c90rScnvXT/HOlwyoNrsQUphQcQuIZ58YbXUYVlCmn ansible-generated on rancher-node-2" >> ~/.ssh/authorized_keys
ssh serverdevops@10.0.0.3
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


