# miq-scripts

All scripts take a hostname prefix parameter.  The examples below work on `vm-foo-{02,03}.example.com` hosts.

## prepare.sh

Create VMs, edit file to set new VMs memory, password, copy ssh keys, generate ansible inventory..
```
> bash prepare.sh foo
```
Contains sudo commands, will ask for password if required.
Also has a couple interactive steps.

## hosts.$hostname_prefix

A host file for openshift-ansible ansible-playbook (prepare.sh called `hosts-generate.sh foo` to create it).

```
> ansible-playbook <PATH-TO-OPENSHIFT-ANSIBLE>/playbooks/byo/config.yml -i hosts.foo
```

## add-metric.sh

Add metric to the openshift
[**Run inside the master VM.**]

```
$ bash add-metric.sh foo
```

----

## delete-vm.sh

Remove VMs from local machine
```
> bash delete-vm.sh foo
```
Contains sudo commands, will ask for password if required.

----

## set-miq-providers.rb

Based on `fill_er_up.sh` from https://github.com/zeari/miq-helpers
