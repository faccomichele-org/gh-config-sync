# ---------------------------------------------------------------------------
# Automatic import of existing repositories
# ---------------------------------------------------------------------------
# On the first run Terraform will import every repository that is:
#   - listed in the 'repositories' section of config/repos.yaml, AND
#   - currently discovered in the organization.
# On subsequent runs the import block is a no-op for already-managed resources.
# Requires Terraform >= 1.7.0 (for_each support in import blocks).
#
# Import ID note: the GitHub provider is configured with `owner = var.org_name`
# in providers.tf, which scopes all operations to that organization.  The
# provider therefore expects just the repository name (not "org/repo") as the
# import ID — consistent with the official provider documentation.
import {
  for_each = local.explicitly_configured
  to       = github_repository.repos[each.key]
  id       = each.key
}

# ---------------------------------------------------------------------------
# Repository settings
# ---------------------------------------------------------------------------
# Only repositories explicitly listed in config/repos.yaml are managed here.
# Discovered repositories that are NOT in the config keep their existing
# settings; Terraform will only manage their labels (see labels.tf).
resource "github_repository" "repos" {
  for_each = local.explicitly_configured

  name         = each.key
  description  = lookup(each.value, "description", null)
  homepage_url = lookup(each.value, "homepage_url", null)

  # visibility is Computed+Optional in the provider: null keeps the existing value.
  visibility = lookup(each.value, "visibility", null)

  # Repository features
  has_issues      = lookup(each.value, "has_issues", null)
  has_discussions = lookup(each.value, "has_discussions", null)
  has_projects    = lookup(each.value, "has_projects", null)
  has_wiki        = lookup(each.value, "has_wiki", null)
  has_downloads   = lookup(each.value, "has_downloads", null)
  is_template     = lookup(each.value, "is_template", null)

  # Merge strategy
  allow_merge_commit          = lookup(each.value, "allow_merge_commit", null)
  merge_commit_title          = lookup(each.value, "merge_commit_title", null)
  merge_commit_message        = lookup(each.value, "merge_commit_message", null)
  allow_squash_merge          = lookup(each.value, "allow_squash_merge", null)
  squash_merge_commit_title   = lookup(each.value, "squash_merge_commit_title", null)
  squash_merge_commit_message = lookup(each.value, "squash_merge_commit_message", null)
  allow_rebase_merge          = lookup(each.value, "allow_rebase_merge", null)
  allow_auto_merge            = lookup(each.value, "allow_auto_merge", null)
  delete_branch_on_merge      = lookup(each.value, "delete_branch_on_merge", null)
  allow_update_branch         = lookup(each.value, "allow_update_branch", null)

  topics               = lookup(each.value, "topics", null)
  vulnerability_alerts = lookup(each.value, "vulnerability_alerts", null)
  archived             = lookup(each.value, "archived", null)

  lifecycle {
    # Prevent accidental repository deletion.
    # To stop managing a repo run:
    #   terraform state rm 'github_repository.repos["<name>"]'
    prevent_destroy = true

    # Fields that are only meaningful at creation time; ignore drift.
    ignore_changes = [auto_init, gitignore_template, license_template, template]
  }
}
