# miq-scripts

## virt-deploy-script-01

Create VMs, edit file to set new VMs memory, password, etc ...
```
> sudo bash virt-deploy-script-01.sh
```

## virt-deploy-script-02

Set VMs ssh authentication
```
> bash virt-deploy-script-02.sh
```

## delete-vm

Remove VMs from local machine
```
> bash delete-vm.sh
```

## add-metric

Add metric to the openshift
[Run on the master VM.]
```
> bash add-metric.sh
```

# hosts.local

A host file for openshift-ansible ansible-playbook

```
> # from inside openshift-ansible directory
> ansible-playbook <PATH-TO-OPENSHIFT-ANSIBLE>/playbooks/byo/config.yml -i hosts.local
```
