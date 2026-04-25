# ---------------------------------------------------------------------------
# Label management
# ---------------------------------------------------------------------------
# Labels are enforced for ALL discovered repositories (not just those in the
# 'repositories' config section).  Labels defined here replace the full label
# set — any label NOT present in the configuration will be removed from the
# repository on the next 'terraform apply'.
#
# Labels that were created outside of Terraform are not automatically deleted
# unless they are first imported into Terraform state:
#   terraform import \
#     'github_issue_label.labels["<repo>/<label>"]' \
#     '<repo>:<label>'
resource "github_issue_label" "labels" {
  for_each = local.all_labels

  repository = each.value.repo
  name       = each.value.name
  # Accept colors with or without a leading '#'.
  color       = trimprefix(each.value.color, "#")
  description = lookup(each.value, "description", "")

  depends_on = [github_repository.repos]
}
