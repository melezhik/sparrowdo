#!raku

bash "modprobe br_netfilter";

file "/etc/sysctl.d/k8s.conf", %(
  action  => 'create',
  content => 'net.bridge.bridge-nf-call-iptables = 1'
);

bash "sysctl --system";

bash "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add";

file "/etc/apt/sources.list.d/kubernetes.list", %(
  action  => 'create',
  content => 'deb https://apt.kubernetes.io/ kubernetes-xenial main'
);

bash "apt-get update";

package-install "kubelet kubeadm";

task-run "install docker", "docker-engine";

if tags()<master> {

  package-install "kubectl";

  task-run "files/tasks/k8s-cluster-init";

} 

