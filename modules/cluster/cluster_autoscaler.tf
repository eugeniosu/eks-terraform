# https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html

resource "aws_iam_policy" "cluster_auto_scaler" {
  name        = "AWSClusterAutoScaler"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeImages",
                "ec2:GetInstanceTypesFromInstanceRequirements",
                "eks:DescribeNodegroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/${local.cluster_name}": "owned"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*"
        }
    ]
}
  EOF

}

module "iam-role-cluster-autoscaler" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  role_name             = "AWSClusterAutoScaler"
  create_role           = true
  force_detach_policies = true
  provider_url          = module.eks.cluster_oidc_issuer_url
  role_policy_arns      = [
    aws_iam_policy.cluster_auto_scaler.id,
  ]
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:cluster-autoscaler"
  ]
 
}
