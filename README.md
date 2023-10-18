# kubernetes-cluster

## Dependencies

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

## Create

```bash
vagrant up
```

That's it.

## Configs

There are several default values that are configured at the top of the `Vagrantfile`:

```
CALICO_VERSION = "3.26.0"
KUBERNETES_VERSION = "1.28.0-00"
OS = "Debian_11"
WORKERS = 2

HOST = 100
NETWORK = "10.0.0."
POD_CIDR = "172.16.1.0/16"
SERVICE_CIDR = "172.17.1.0/18"
```

Change as needed.

> By default, this project uses the [`cri-o`](https://cri-o.io/) container runtime and the [Calico](https://docs.tigera.io/calico/latest/about/) network policy.

## License

[GPLv3](COPYING)

## Author

Benjamin Toll

