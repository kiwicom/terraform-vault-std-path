# terraform-vault-std-path

Terraform module for standardized paths - shared & third party 

- creates `kw/[TYPE]/[PATH][-maintainer]` policies
- `maintainer_groups` is mandatory

### Shared

- I cannot figure out a good example of a shared secret, but we have the option
- `roles` parameter usually does not make sense

```hcl
module "shared_automation" {
  source  = "kiwicom/std-path/vault"
  version = "1.0.0"

  path = "automation/i-dont-know"
  type = "shared"

  maintainer_groups = [
    "engineering.automation-seniors"
  ]
}
```

- creates `kw/shared/automation/i-dont-know[-maintainer]` policies which allows access to the same path
- and assigns maintainer to the `maintainer_groups`

### 3rd party
- any 3rd party company should have a contact person (or group) in kiwi. This person/group is responsible for 
 communication and also for secrets management - they should get the secrets from the 3rd party and paste it to vault
 
```hcl
module "third_party_some_company" {
  source  = "kiwicom/std-path/vault"
  version = "1.0.0"

  path = "some-company"
  type = "3rd-party"

  maintainer_groups = [
    "engineering.automation-seniors"
  ]
}
```
- `third_party_some_company` is an example of a simple 3rd party secret used by one team/app - it is defined in 
 the team's file near the rest of their apps

```hcl
module "third_party_datadog" {
  source  = "kiwicom/std-path/vault"
  version = "1.0.0"

  path = "datadog"
  type = "3rd-party"

  maintainer_groups = [
    "engineering.platform.appsec-seniors"
  ]

  roles = [
    "gcp-projects-terraform",
    "gtmhub-jira",
    "k8s-gcp-projects",
    # ...
  ]
}
```

- `datadog` is widely used in many teams in kiwi
- `roles` parameter is used to define different credentials for each team maybe even distinguish sandbox and production
- for each role, we create a special policy named `kw/[TYPE]/[PATH]/creds/[ROLE]` which grants access to the same path
- if at least one role is specified then general use policy `kw/[TYPE]/[PATH]` is not created (and `use_groups`) 
 does not make sense at all

### Notes
- the setup allows us to have different permissions for an app running in cluster in k8s and for developer
