output "github_actions_role_arn" {
  value = module.iam_github_actions.github_actions_role_arn
  description = "ARN of the IAM role for GitHub Actions."
}
