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

  service-start "kubelet";

  bash q:to/HERE/, %( user => "ubuntu", description => "install flannel");
    set -e;
    echo "run [kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml]"
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  HERE

  task-run "check master", "k8s-master-check", %(
    user => "ubuntu"
  );
  
} elsif tags()<worker> {

  if tags()<token> && tags()<cert_hash> {
    bash "kubeadm join {tags()<master_ip>}:6443 --token {tags()<token>} --discovery-token-ca-cert-hash sha256:{tags<cert_hash>}", %(
    debug => True
    );
  } else {
    say "token and/or cerh_hash parameters are not passed, skip node join to cluster stage"
  }

}

