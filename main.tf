# policy
resource "vault_policy" "path" {
  count  = length(var.roles) < 1 ? 1 : 0
  name   = "kw/${var.type}/${var.path}"
  policy = <<EOT
path "kw/${var.type}/${var.path}/*" {
  capabilities = ["read", "list"]
}
path "kw/${var.type}/${var.path}/" {
  capabilities = ["read", "list"]
}
path "kw/${var.type}/${var.path}" {
  capabilities = ["read"]
}
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

# policy-maintainer
resource "vault_policy" "path_maintainers" {
  name   = "kw/${var.type}/${var.path}-maintainer"
  policy = <<EOT
# access namespace, stage specific secrets
path "kw/${var.type}/${var.path}/*" {
  capabilities = ["create", "update", "read", "delete", "list"]
}
path "kw/${var.type}/${var.path}/" {
  capabilities = ["create", "update", "read", "delete", "list"]
}
path "kw/${var.type}/${var.path}" {
  capabilities = ["create", "update", "read", "delete"]
}
path "kw/${var.type}/data/${var.path}/*" {
  capabilities = ["create", "update", "read", "delete"]
}
path "kw/${var.type}/metadata/${var.path}" {
  capabilities = ["create", "update", "read", "delete", "list"]
}
path "kw/${var.type}/metadata/${var.path}/*" {
  capabilities = ["create", "update", "read", "delete", "list"]
}
EOT
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
path "kw/${var.type}/${var.path}/creds/${each.value}" {
  capabilities = ["read", "list"]
}
path "kw/${var.type}/${var.path}/creds/${each.value}" {
  capabilities = ["read", "list"]
}
path "kw/${var.type}/data/${var.path}/creds/${each.value}" {
  capabilities = ["read"]
}
path "kw/${var.type}/metadata/${var.path}/creds/${each.value}" {
  capabilities = ["read", "list"]
}
EOT
}
