# downloaded from https://github.com/cyberark/conjur-policy-library

This repo contains policy samples (found in /policies and /delegation) intended to help customers get started working with production level policies.
Each file resides in a folder named for the policy branch the policy is intended for.
Each file is prefixed with a numerical value, allowing the files to be concatenated together and loaded in a single pass.
We can load policy from stdin by using `-`
Thus the policy load command would be something like `cat $(ls -A)|conjur policy load --replace <branch> -`

Customers could clone this repo and have management for their root policy as well as the creation of policy namespaces for app and developer teams. These teams would then manage their own repos for policy management of their policy namespace.

Policy management best practices:
1. Manage policies with a source code management tool
2. Load policies with the `--replace` option
3. Delegate policy management to other teams by creating a namespace for them
4. Manage ACLs with groups.
5. Manage hosts with groups (aside from HostFactory, layers and groups behave identically, and layers might not even be necessary for HF to work. Need to test this)
6. Avoid implicit definitions. For example, if one does not provide a name for a resource, that resource inherits the name of the policy it's created in. So in the example below, a resource named `layer:my_pol` would be created.
`---
- !policy my_pol
  body:
  - !layer`
However, if you explicitly defined the layer name as `my_pol`, a la:
`---
- !policy my_pol
  body:
  - !layer my_pol`
This policy will create a resource named `layer:my_pol/my_pol`.
This becomes difficult to follow in large policy files and is best to avoid.
