# ---------------------------------------------------------------------------
# Environment management
# ---------------------------------------------------------------------------
# Environments are only configured for repositories explicitly listed in the
# 'repositories' section of config/repos.yaml.
#
# Note: the 'reviewers.users' and 'reviewers.teams' fields accept numeric IDs,
# not usernames/team slugs.  Retrieve them via the GitHub API or use the
# github_user / github_team data sources in your configuration.
resource "github_repository_environment" "environments" {
  for_each = local.all_environments

  repository          = each.value.repo
  environment         = each.value.name
  wait_timer          = lookup(each.value, "wait_timer", null)
  can_admins_bypass   = lookup(each.value, "can_admins_bypass", null)
  prevent_self_review = lookup(each.value, "prevent_self_review", null)

  dynamic "reviewers" {
    for_each = lookup(each.value, "reviewers", null) != null ? [each.value.reviewers] : []
    content {
      users = lookup(reviewers.value, "users", [])
      teams = lookup(reviewers.value, "teams", [])
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = lookup(each.value, "deployment_branch_policy", null) != null ? [each.value.deployment_branch_policy] : []
    content {
      protected_branches     = lookup(deployment_branch_policy.value, "protected_branches", true)
      custom_branch_policies = lookup(deployment_branch_policy.value, "custom_branch_policies", false)
    }
  }

  depends_on = [github_repository.repos]
}
