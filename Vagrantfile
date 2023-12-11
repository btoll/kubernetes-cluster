# -*- mode: ruby -*-
# vi: set ft=ruby :

CALICO_VERSION = "3.26.0"
KUBERNETES_VERSION = "1.27.0-00"
OS = "Debian_11"
WORKERS = 0

HOST = 100
NETWORK = "10.0.0."
POD_CIDR = "172.16.1.0/16"
# Use this pod cidr so the manifests don't need to be altered with a different cidr.
# ( This is the default flannel cidr. )
#POD_CIDR = "10.244.0.0/16"
SERVICE_CIDR = "172.17.1.0/18"

Vagrant.configure("2") do |config|
    # Common.
    config.vm.box =  "debian/bullseye64"

    config.vm.synced_folder ".", "/vagrant"
    config.ssh.forward_agent = true

    config.vm.provider :virtualbox do |vb|
        vb.cpus = 8
        vb.gui = false
        vb.customize ["modifyvm", :id, "--groups", "/kilgore"]
    end

    # Common shell scripts.
    config.vm.provision "shell",
        env: {
            "HOST" => HOST,
            "NETWORK" => NETWORK,
            "WORKERS" => WORKERS
        },
        path: "scripts/setup.sh"

    config.vm.provision "shell",
        env: {
            "OS" => OS,
            "KUBERNETES_VERSION" => KUBERNETES_VERSION
        },
        path: "scripts/common/container_runtime.sh"

    config.vm.provision "shell",
        env: {
            "KUBERNETES_VERSION" => KUBERNETES_VERSION
        },
        path: "scripts/common/kubetools.sh"

    config.vm.provision "shell", path: "scripts/common/vendor.sh"

    # Master.
    config.vm.define "master" do |master|
        master.vm.hostname = "master"
        master.vm.network "private_network", ip: "#{NETWORK}#{HOST}"

        master.vm.provider :virtualbox do |vb|
#            vb.memory = 12288
            vb.memory = 20480
        end

        master.vm.provision "shell",
            env: {
                "CALICO_VERSION" => CALICO_VERSION,
                "CONTROL_PLANE_IP" => "#{NETWORK}#{HOST}",
                "POD_CIDR" => POD_CIDR,
                "SERVICE_CIDR" => SERVICE_CIDR
            },
            path: "scripts/master.sh"
    end

    # Workers.
    (1..WORKERS).each do |i|
        config.vm.define "worker#{i}" do |worker|
            worker.vm.provider :virtualbox do |vb|
                vb.memory = 8192
            end

            worker.vm.hostname = "worker#{i}"
            worker.vm.network "private_network", ip: "#{NETWORK}#{HOST + i}"
            worker.vm.provision "shell", path: "scripts/worker.sh"
        end
    end
end

