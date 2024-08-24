# Run Gitlab

```
instance_internal_ips = [
  "10.0.0.4",
]
instance_ips = [
  "34.45.189.254",
]
ssh -i docker-node/docker-key.pem docker@34.45.189.254
sudo su
cd /tmp
docker compose up -d
```