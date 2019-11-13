# Redis specific configurations

Before deploying stack open `/etc/sysctl.conf` and add the following

```
vm.overcommit_memory = 1
net.core.somaxconn = 65535
```