output "discovered_repositories" {
  description = "All non-archived repositories discovered in the organization."
  value       = sort(tolist(local.all_discovered))
}

output "managed_repositories" {
  description = "Repositories fully managed by Terraform (listed in the 'repositories' config section)."
  value       = sort(keys(local.explicitly_configured))
}

output "label_managed_repositories" {
  description = "Repositories whose labels are managed by Terraform (all discovered repos)."
  value       = sort(keys(local.all_target_repos))
}

output "repo_filter_active" {
  description = "Whether a single-repository filter is currently active."
  value       = var.repo_filter != ""
}

output "active_repo_filter" {
  description = "The repository name used as a filter, or null when no filter is active."
  value       = var.repo_filter != "" ? var.repo_filter : null
}
