resource "aws_sns_topic" "this" {
      
}

resource "aws_ssm_parameter" "this" {
  name = "/samples/iam-role/TopicArn"
  value = aws_sns_topic.this.arn
  type = "String"
}

resource "random_string" "this" {
  length = 8
  special = false
}

resource "aws_iam_user" "this" {
  name = random_string.this.result
  path = "/samples/iamroles/"
}

resource "aws_iam_user_policy" "this" {
  user = aws_iam_user.this.name
  
  policy = jsonencode({
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/samples/iamroles/*"
        ]
      }
    ]
  })
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.this.arn]
    }

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "ssm_parameters" {
    statement {
        effect = "Allow"
        actions = ["ssm:DescribeParameters"]
        resources = ["*"]
    }

    statement {
        effect = "Allow"
        actions = ["ssm:GetParametersByPath"]
        resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/samples/iam-role/"]
    }
}

resource "aws_iam_role" "role_with_permission" {
  name = "role_with_permission"
  path = "/samples/iamroles/"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  inline_policy {
    name = "sns"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["sns:Publish"]
          Effect   = "Allow"
          Resource = aws_sns_topic.this.arn
        },
      ]
    })
  }

  inline_policy {
    name = "ssm"
    policy = data.aws_iam_policy_document.ssm_parameters.json
  }
}

resource "aws_iam_role" "role_without_permission" {
  name = "role_without_permission"
  path = "/samples/iamroles/"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  inline_policy {
    name = "ssm"
    policy = data.aws_iam_policy_document.ssm_parameters.json
  }
}