# Run Gitlab

```
instance_internal_ips = [
  "10.0.0.4",
]
instance_ips = [
  "34.68.131.157",
]
ssh -i docker-node/docker-key.pem docker@34.68.131.157
sudo su
cd /tmp
docker compose up -d
```