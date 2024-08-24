# Run Gitlab

```
instance_internal_ips = [
  "10.0.0.4",
]
instance_ips = [
  "104.155.187.17",
]
ssh -i docker-node/docker-key.pem docker@104.155.187.17
```

```
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```