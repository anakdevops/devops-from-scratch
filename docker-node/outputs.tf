# Output the public IPs of all instances
output "instance_ips" {
  value = [for instance in google_compute_instance.vm_instance : instance.network_interface[0].access_config[0].nat_ip]
}

# Output the internal IPs of all instances
output "instance_internal_ips" {
  value = [for instance in google_compute_instance.vm_instance : instance.network_interface[0].network_ip]
}