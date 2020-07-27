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

  directory "/home/ubuntu/.kube", %(
    owner => "ubuntu",
    group => "ubuntu",
  );

  file "/home/ubuntu/.kube/config", %(
    owner => "ubuntu",
    group => "ubuntu",
    source => "/etc/kubernetes/admin.conf"
  );


  bash q:to/HERE/, %( user => "ubuntu", description => "install flannel");
    set -e;
    rm -rf pod_network_setup.txt
    if test -f pod_network_setup.txt; then
      echo "flannel already installed"
      echo "========================="
      cat pod_network_setup.txt
    else
      echo "run [kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml]"
      kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml >> pod_network_setup.txt
      cat pod_network_setup.txt
    fi
  HERE

} 

