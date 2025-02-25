output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the created subnet"
  value       = aws_subnet.main.id
}

output "internet_gateway_id" {
  description = "The ID of the created internet gateway"
  value       = aws_internet_gateway.gw.id
}

output "route_table_id" {
  description = "The ID of the created route table"
  value       = aws_route_table.rt.id
}