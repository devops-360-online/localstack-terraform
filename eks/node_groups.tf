
resource "aws_iam_role" "eks_managed_nodegroup_role" {
  name = "Zeta_EKS_Managed_Nodegroup_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
      }
    ]
  })

  tags = {
    owner = "example"
  }
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_managed_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_managed_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_managed_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.eks_managed_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "cluster_critical_node_group" {
  cluster_name    = "example"
  node_group_name = "system-managed-workers-001"
  node_role_arn   = aws_iam_role.eks_managed_nodegroup_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config {
    min_size     = 1
    max_size     = 5
    desired_size = 1
  }

  instance_types = ["t2.micro"]
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  update_config {
    max_unavailable = 1
  }

  labels = {
    "node.kubernetes.io/scope" = "system"
  }

  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_EXECUTE"
  }


  tags = {
    owner = "example"
  }
}

resource "aws_eks_node_group" "application_node_group" {
  cluster_name    = "example"
  node_group_name = "application-managed-workers-001"
  node_role_arn   = aws_iam_role.eks_managed_nodegroup_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config {
    min_size     = 1
    max_size     = 5
    desired_size = 1
  }

  instance_types = ["t2.micro"]
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  update_config {
    max_unavailable = 1
  }

  labels = {
    "node.kubernetes.io/scope" = "application"
  }


  tags = {
    owner = "example"
  }
}
