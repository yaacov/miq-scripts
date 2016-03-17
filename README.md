# miq-scripts

All scripts take a hostname prefix parameter.  The examples below work on `vm-foo-{02,03}.example.com` hosts.

## virt-deploy-script-01

Create VMs, edit file to set new VMs memory, password, etc ...
```
> sudo bash virt-deploy-script-01.sh foo
```

## virt-deploy-script-02

Set VMs ssh authentication
```
> bash virt-deploy-script-02.sh foo
```

## delete-vm

Remove VMs from local machine
```
> bash delete-vm.sh foo
```

## add-metric

Add metric to the openshift
[Run on the master VM.]
```
> bash add-metric.sh foo
```

# hosts.local

A host file for openshift-ansible ansible-playbook

```
> bash hosts.local-generate.sh foo
> ansible-playbook <PATH-TO-OPENSHIFT-ANSIBLE>/playbooks/byo/config.yml -i hosts.local
```
