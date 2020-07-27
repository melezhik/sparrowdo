set -e

#rm -rf /home/ubuntu/cluster_initialized.txt;

if test -f /home/ubuntu/cluster_initialized.txt; then
  echo "claster already initialized"
  echo "==========================="
  cat /home/ubuntu/cluster_initialized.txt
else
  kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU >> /home/ubuntu/cluster_initialized.txt
  echo "run [kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU]"
  echo "==================================================="
  cat /home/ubuntu/cluster_initialized.txt
fi
