# ---------------------------------------------------------------------------
# Repository ruleset management
# ---------------------------------------------------------------------------
# Rulesets are only configured for repositories explicitly listed in the
# 'repositories' section of config/repos.yaml.
#
# Supported targets: "branch" | "tag"
# Supported enforcement levels: "active" | "evaluate" | "disabled"
#
# bypass_actors.actor_type values:
#   "RepositoryRole" | "Team" | "Integration" | "OrganizationAdmin"
resource "github_repository_ruleset" "rulesets" {
  for_each = local.all_rulesets

  name        = each.value.name
  repository  = each.value.repo
  target      = lookup(each.value, "target", "branch")
  enforcement = lookup(each.value, "enforcement", "active")

  # ── Bypass actors ──────────────────────────────────────────────────────────
  dynamic "bypass_actors" {
    for_each = lookup(each.value, "bypass_actors", [])
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = lookup(bypass_actors.value, "bypass_mode", "always")
    }
  }

  # ── Conditions ────────────────────────────────────────────────────────────
  dynamic "conditions" {
    for_each = lookup(each.value, "conditions", null) != null ? [each.value.conditions] : []
    content {
      ref_name {
        include = lookup(lookup(conditions.value, "ref_name", {}), "include", [])
        exclude = lookup(lookup(conditions.value, "ref_name", {}), "exclude", [])
      }
    }
  }

  # ── Rules ─────────────────────────────────────────────────────────────────
  rules {
    # Simple boolean rules
    creation                      = try(each.value.rules.creation, null)
    deletion                      = try(each.value.rules.deletion, null)
    non_fast_forward              = try(each.value.rules.non_fast_forward, null)
    required_linear_history       = try(each.value.rules.required_linear_history, null)
    required_signatures           = try(each.value.rules.required_signatures, null)
    update                        = try(each.value.rules.update, null)
    update_allows_fetch_and_merge = try(each.value.rules.update_allows_fetch_and_merge, null)

    # Branch name pattern (branch rulesets only)
    dynamic "branch_name_pattern" {
      for_each = try(each.value.rules.branch_name_pattern, null) != null ? [each.value.rules.branch_name_pattern] : []
      content {
        operator = branch_name_pattern.value.operator
        pattern  = branch_name_pattern.value.pattern
        name     = lookup(branch_name_pattern.value, "name", null)
        negate   = lookup(branch_name_pattern.value, "negate", false)
      }
    }

    # Tag name pattern (tag rulesets only)
    dynamic "tag_name_pattern" {
      for_each = try(each.value.rules.tag_name_pattern, null) != null ? [each.value.rules.tag_name_pattern] : []
      content {
        operator = tag_name_pattern.value.operator
        pattern  = tag_name_pattern.value.pattern
        name     = lookup(tag_name_pattern.value, "name", null)
        negate   = lookup(tag_name_pattern.value, "negate", false)
      }
    }

    # Commit message pattern
    dynamic "commit_message_pattern" {
      for_each = try(each.value.rules.commit_message_pattern, null) != null ? [each.value.rules.commit_message_pattern] : []
      content {
        operator = commit_message_pattern.value.operator
        pattern  = commit_message_pattern.value.pattern
        name     = lookup(commit_message_pattern.value, "name", null)
        negate   = lookup(commit_message_pattern.value, "negate", false)
      }
    }

    # Commit author email pattern
    dynamic "commit_author_email_pattern" {
      for_each = try(each.value.rules.commit_author_email_pattern, null) != null ? [each.value.rules.commit_author_email_pattern] : []
      content {
        operator = commit_author_email_pattern.value.operator
        pattern  = commit_author_email_pattern.value.pattern
        name     = lookup(commit_author_email_pattern.value, "name", null)
        negate   = lookup(commit_author_email_pattern.value, "negate", false)
      }
    }

    # Committer email pattern
    dynamic "committer_email_pattern" {
      for_each = try(each.value.rules.committer_email_pattern, null) != null ? [each.value.rules.committer_email_pattern] : []
      content {
        operator = committer_email_pattern.value.operator
        pattern  = committer_email_pattern.value.pattern
        name     = lookup(committer_email_pattern.value, "name", null)
        negate   = lookup(committer_email_pattern.value, "negate", false)
      }
    }

    # Pull request rules
    dynamic "pull_request" {
      for_each = try(each.value.rules.pull_request, null) != null ? [each.value.rules.pull_request] : []
      content {
        dismiss_stale_reviews_on_push     = lookup(pull_request.value, "dismiss_stale_reviews_on_push", false)
        require_code_owner_review         = lookup(pull_request.value, "require_code_owner_review", false)
        require_last_push_approval        = lookup(pull_request.value, "require_last_push_approval", false)
        required_approving_review_count   = lookup(pull_request.value, "required_approving_review_count", 0)
        required_review_thread_resolution = lookup(pull_request.value, "required_review_thread_resolution", false)
      }
    }

    # Required status checks
    dynamic "required_status_checks" {
      for_each = try(each.value.rules.required_status_checks, null) != null ? [each.value.rules.required_status_checks] : []
      content {
        strict_required_status_checks_policy = lookup(required_status_checks.value, "strict_required_status_checks_policy", false)

        dynamic "required_check" {
          for_each = lookup(required_status_checks.value, "required_checks", [])
          content {
            context        = required_check.value.context
            integration_id = lookup(required_check.value, "integration_id", null)
          }
        }
      }
    }

    # Required deployments
    dynamic "required_deployments" {
      for_each = try(each.value.rules.required_deployments, null) != null ? [each.value.rules.required_deployments] : []
      content {
        required_deployment_environments = lookup(required_deployments.value, "environments", [])
      }
    }
  }

  depends_on = [github_repository.repos]
}
