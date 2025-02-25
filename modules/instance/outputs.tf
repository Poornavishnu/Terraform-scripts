output "control_node_ip" {
  description = "Public IP of the control node"
  value       = aws_instance.control_node.public_ip
}

output "worker_node_ips" {
  description = "Public IPs of the worker nodes"
  value       = aws_instance.worker_nodes[*].public_ip
}