resource "aws_iam_policy" "external_dns" {
  name = "ExternalDNS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      },
    ]
  })

}

module "irsa_external_dns" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version               = "5.2.0"

  role_name             = "ExternalDNS"
  create_role           = true
  force_detach_policies = true
  provider_url          = module.eks.cluster_oidc_issuer_url
  role_policy_arns      = [
    aws_iam_policy.external_dns.id,
  ]
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:external-dns"
  ]

}

output "external_dns_iam_role_arn" {
  value = module.irsa_external_dns.iam_role_arn
}
