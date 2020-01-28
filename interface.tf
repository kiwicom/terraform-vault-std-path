variable "path" {
  type        = string
  description = "Path after kw/[TYPE]/..."
}

variable "type" {
  type        = string
  description = "Secret type, will be part of path, allowed values: '3rd-party', 'shared'"
}

variable "use_groups" {
  default     = []
  description = "Bad practice: use assignment to developers groups in application-registry"
}

variable "roles" {
  default = []
}

variable "maintainer_groups" {
  type = list
}

locals {
  allowed_types = ["3rd-party", "shared"]
}

resource "null_resource" "assert_allowed_type" {
  triggers = contains(local.allowed_types, var.type) ? {} : file("Type should be '3rd-party' or 'shared' ")
  lifecycle {
    ignore_changes = [
      triggers
    ]
  }
}

output "use_policy" {
  value = length(var.roles) < 1 ? vault_policy.path[0].name : ""
}

output "maintainer_policy" {
  value = vault_policy.path_maintainers.name
}

output "role_policies" {
  value = zipmap(var.roles, [for policy in vault_policy.roles : policy.name])
}
