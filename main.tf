# policy
resource "vault_policy" "path" {
  count  = length(var.roles) < 1 ? 1 : 0
  name   = "kw/${var.type}/${var.path}"
  policy = <<EOT
path "kw/${var.type}/data/${var.path}/*" {
  capabilities = ["read"]
}
path "kw/${var.type}/metadata/${var.path}" {
  capabilities = ["read", "list"]
}
path "kw/${var.type}/metadata/${var.path}/*" {
  capabilities = ["read", "list"]
}
EOT
}

data "vault_policy_document" "path_maintainers" {
  rule {
    capabilities = ["create", "update", "read", "delete", "list"]
    path = "kw/${var.type}/data/${var.path}/*"
  }

  rule {
    capabilities = ["create", "update", "read", "delete", "list"]
    path = "kw/${var.type}/metadata/${var.path}/*"
  }

  dynamic rule {
    for_each = split("/", var.path)
    content {
      path         = "kw/${var.type}/metadata/${join("/", slice(split("/", var.path), 0, rule.key))}"
      capabilities = ["list"]
      description  = "list of subpath"
    }
  }
}

# policy-maintainer
resource "vault_policy" "path_maintainers" {
  name   = "kw/${var.type}/${var.path}-maintainer"
  policy = data.vault_policy_document.path_maintainers.hcl
}

# assignment
data "vault_identity_group" "path" {
  for_each   = toset(var.use_groups)
  group_name = each.value
}

resource "vault_identity_group_policies" "path" {
  for_each  = toset(var.use_groups)
  group_id  = data.vault_identity_group.path[each.value].group_id
  policies  = [vault_policy.path[0].name]
  exclusive = false
}

# assignment-maintainer
data "vault_identity_group" "path_maintainers" {
  for_each   = toset(var.maintainer_groups)
  group_name = each.value
}

resource "vault_identity_group_policies" "path_maintainers" {
  for_each  = toset(var.maintainer_groups)
  group_id  = data.vault_identity_group.path_maintainers[each.value].group_id
  policies  = [vault_policy.path_maintainers.name]
  exclusive = false
}

resource "vault_policy" "roles" {
  for_each = toset(var.roles)
  name     = "kw/${var.type}/${var.path}/creds/${each.value}"
  policy   = <<EOT
path "kw/${var.type}/data/${var.path}/creds/${each.value}" {
  capabilities = ["read"]
}
path "kw/${var.type}/metadata/${var.path}/creds/${each.value}" {
  capabilities = ["read", "list"]
}
EOT
}
