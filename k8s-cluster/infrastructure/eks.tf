resource "aws_iam_role" "prj-eks" {
  name = "${local.project_name_common}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prj-eks-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.prj-eks.name
}

resource "aws_eks_cluster" "prj" {
  depends_on = [
    aws_iam_role_policy_attachment.prj-eks-cluster
  ]
  name     = "${var.project_name}-eks"
  role_arn = aws_iam_role.prj-eks.arn
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = concat(aws_subnet.prj-eks-public.*.id, aws_subnet.prj-eks-private.*.id)
  }
}

resource "aws_iam_role" "prj-eks-nodes" {
  name = "${local.project_name_common}-eks-nodes-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prj-eks-worker-nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.prj-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "prj-eks-cni-nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.prj-eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "prj-eks-registry-nodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.prj-eks-nodes.name
}

resource "aws_eks_node_group" "prj-eks" {
  depends_on = [
    aws_iam_role_policy_attachment.prj-eks-worker-nodes,
    aws_iam_role_policy_attachment.prj-eks-cni-nodes,
    aws_iam_role_policy_attachment.prj-eks-registry-nodes
  ]
  cluster_name    = aws_eks_cluster.prj.name
  node_group_name = "${var.project_name}-eks-ng"
  node_role_arn   = aws_iam_role.prj-eks-nodes.arn
  subnet_ids      = aws_subnet.prj-eks-private.*.id
  scaling_config {
    desired_size = var.project_aws_eks_ng_scaling_config_desired
    max_size     = var.project_aws_eks_ng_scaling_config_max
    min_size     = var.project_aws_eks_ng_scaling_config_min
  }
  ami_type             = var.project_aws_eks_ng_ami_type
  capacity_type        = var.project_aws_eks_ng_capacity_type
  disk_size            = var.project_aws_eks_ng_disk_size
  force_update_version = false
  instance_types       = var.project_aws_eks_ng_instance_types
}

data "tls_certificate" "prj-eks" {
  url = aws_eks_cluster.prj.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "prj-eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.prj-eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.prj.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.project_name}-eks-iam-ocp"
  }
}

data "aws_iam_policy_document" "prj-eks-csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.prj-eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.prj-eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "prj-eks-csi" {
  assume_role_policy = data.aws_iam_policy_document.prj-eks-csi.json
  name               = "${var.project_name}-eks-csi-role"
}

resource "aws_iam_role_policy_attachment" "prj-eks-csi" {
  role       = aws_iam_role.prj-eks-csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "prj-eks-csi" {
  depends_on               = [aws_eks_node_group.prj-eks]
  addon_name               = "aws-ebs-csi-driver"
  cluster_name             = aws_eks_cluster.prj.name
  service_account_role_arn = aws_iam_role.prj-eks-csi.arn
}
