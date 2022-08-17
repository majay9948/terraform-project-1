provider "kubernetes" {
    # version = "2.12.0"
    # load_config_file = false
    load_config_file = "false"
    version = "~> 1.10"
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
  
}

data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "myapp-cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.2.1"

  cluster_name = "myapp_vpc"
#   cluster_version = "1.17"
  cluster_version = "1.22"

  subnets = module.myapp_vpc.private_subnets
  vpc_id = module.myapp_vpc.vpc_id

  tags = {
    environment = "development"
    application = "myapp"
  }
  worker_groups = [
    {
        instance_type = "t2.small"
        name="worker_group_1"
        asg_desired_capacity=2

    },
    {
        instance_type="t2.medium"
        name="worker_group_2"
        asg_desired_capacity=1
    }
  ]
}