output "role_with_permission" {
    value = aws_iam_role.role_with_permission.arn
}

output "role_without_permission" {
    value = aws_iam_role.role_without_permission.arn
}

output "secret_key" {
    value = aws_iam_access_key.this.secret
    sensitive = true
}

output "access_key" {
    value = aws_iam_access_key.this.id
}

output "topic" {
    value = aws_sns_topic.this.arn
}