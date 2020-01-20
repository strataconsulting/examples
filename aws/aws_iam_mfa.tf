data "aws_caller_identity" "current" {}

locals {
  aws_account = data.aws_caller_identity.current.account_id
}

resource "aws_iam_policy" "enforce_mfa" {
  name        = "Enforce_MFA"
  description = "Allow Users to Add/Edit/Delete Their MFA Configuration and Enforce MFA for any other actions"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAllUsersToListAccounts",
      "Effect": "Allow",
      "Action": [
        "iam:ListAccountAliases",
        "iam:ListUsers"
      ],
      "Resource": [
        "arn:aws:iam::${local.aws_account}:user/*"
      ]
    },
    {
      "Sid": "AllowIndividualUserToSeeTheirAccountInformation",
      "Effect": "Allow",
      "Action": [
        "iam:ChangePassword",
        "iam:CreateLoginProfile",
        "iam:DeleteLoginProfile",
        "iam:GetAccountPasswordPolicy",
        "iam:GetAccountSummary",
        "iam:GetLoginProfile",
        "iam:UpdateLoginProfile"
      ],
      "Resource": [
        "arn:aws:iam::${local.aws_account}:user/$${aws:username}"
      ]
    },
    {
      "Sid": "AllowIndividualUserToListTheirMFA",
      "Effect": "Allow",
      "Action": [
        "iam:ListVirtualMFADevices",
        "iam:ListMFADevices"
      ],
      "Resource": [
        "arn:aws:iam::${local.aws_account}:mfa/*",
        "arn:aws:iam::${local.aws_account}:user/$${aws:username}"
      ]
    },
    {
      "Sid": "AllowIndividualUserToManageTheirMFA",
      "Effect": "Allow",
      "Action": [
        "iam:CreateVirtualMFADevice",
        "iam:DeactivateMFADevice",
        "iam:DeleteVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ResyncMFADevice"
      ],
      "Resource": [
        "arn:aws:iam::${local.aws_account}:mfa/$${aws:username}",
        "arn:aws:iam::${local.aws_account}:user/$${aws:username}"
      ]
    },
    {
      "Sid": "DoNotAllowAnythingOtherThanAboveUnlessMFAd",
      "Effect": "Deny",
      "NotAction": "iam:*",
      "Resource": "*",
      "Condition": {
          "Null": {
              "aws:MultiFactorAuthAge": "true"
          }
      }
    }
  ]
}
EOF
}
