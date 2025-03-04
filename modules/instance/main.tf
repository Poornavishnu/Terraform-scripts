resource "aws_instance" "control_node" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.vpc_security_group_id]
  iam_instance_profile   = var.iam_instance_profile  # ✅ Correct: Use passed variable

  tags = {
    Name = "${var.cluster_name}-control-node"
    Role = "control"
  }
}

resource "aws_instance" "worker_nodes" {
  count                  = 2
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.vpc_security_group_id]
  iam_instance_profile   = var.iam_instance_profile  # ✅ Correct: Use passed variable
  
  tags = {
    Name = "${var.cluster_name}-worker-node-${count.index}"
    Role = "worker"
  }
}