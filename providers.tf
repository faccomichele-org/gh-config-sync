terraform {
  required_version = ">= 1.7.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Authentication uses the PAT supplied via var.github_token.
# The 'owner' setting scopes all resource operations to the target organization
# so resource IDs only need the repository name (no "org/" prefix).
provider "github" {
  token = var.github_token
  owner = var.org_name
}
