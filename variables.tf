variable "github_token" {
  description = "GitHub Personal Access Token used for authentication. Required scopes: repo, admin:org."
  type        = string
  sensitive   = true
}

variable "org_name" {
  description = "Name of the GitHub organization to manage."
  type        = string
}

variable "repo_filter" {
  description = <<-EOT
    Optional: restrict Terraform to a single repository name.
    Useful for testing changes before rolling them out to the whole organization.
    Leave as "" (default) to process all discovered repositories.
  EOT
  type        = string
  default     = ""
}

variable "config_file" {
  description = "Path to the YAML configuration file that defines the desired state for repositories."
  type        = string
  default     = "config/repos.yaml"
}
