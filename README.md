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

## virt-deploy-script-03

Remove VMs from local machine
```
> bash virt-deploy-script-03.sh
```

# hosts.local

Openshift ansible hosts file for local machine

```
> # from inside openshift-ansible directory
> ansible-playbook playbooks/byo/config.yml -i <PATH>/hosts.local
```
