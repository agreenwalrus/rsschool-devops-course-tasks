# AWS VPC Infrastructure with Bastion Host and K3s Kubernetes Cluster

This Terraform project creates a secure AWS VPC infrastructure with public and private subnets, a bastion host for secure access, NAT Gateway for outbound connectivity, and a k3s Kubernetes cluster deployment.

## Infrastructure Components

- **VPC**: A Virtual Private Cloud with CIDR block 10.0.0.0/16
- **Public Subnets**: 1 public subnet in the first availability zone
- **Private Subnets**: 2 private subnets in different availability zones
- **Internet Gateway**: Allows communication between instances in the VPC and the internet
- **NAT Gateway**: Provides outbound internet connectivity for instances in private subnets
- **Bastion Host**: Secure entry point for SSH access to instances in private subnets
- **K3s Cluster**: Lightweight Kubernetes cluster with 2 nodes (1 master + 1 worker)
- **Security Groups**: Configured for bastion host, k3s cluster communication, and inter-subnet connectivity

## Network Connectivity

- Instances in all subnets can communicate with each other
- Instances in public subnets have direct internet access
- Instances in private subnets can access the internet through the NAT Gateway
- External access to private instances is only possible through the bastion host
- K3s cluster nodes communicate over secure internal network

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed (version >= 1.0.0)
- SSH key pair created in AWS
- kubectl installed on your local machine (for cluster management)
- For k3s Server Node minimum hardware requirements are 2 CPUs and 2 Gb RAM
- For k3s Agent Node minimum hardware requirements are 1 CPUs and 512 Mb RAM

## Usage

1. Clone this repository
2. Update the `terraform.tfvars` file with your specific values. Use `terraform.tfvars` as reference:



3. Initialize Terraform:

```bash
terraform init
```

4. Apply the Terraform configuration:

```bash
terraform apply
```

5. After successful deployment, you'll see outputs including the bastion host's public IP address and k3s cluster node information.

## Getting Terraform Outputs

After successful deployment, you can retrieve important information using Terraform outputs:

```powershell
# Get all outputs
terraform output

# Get specific outputs for k3s setup
terraform output bastion_public_ip
terraform output ec2_private_k3s_server_private_ips
terraform output ec2_private_k3s_agent_private_ips
```

### Key Outputs for K3s Setup:
- **bastion_public_ip**: Use this to SSH to the bastion host
- **ec2_private_k3s_server_private_ips**: Private IP of the k3s master node
- **ec2_private_k3s_agent_private_ips**: Private IPs of the k3s worker nodes

## K3s Kubernetes Cluster Setup

### Cluster Architecture
- **Server(Master) Node (k3s-server)**: Deployed in the first private subnet, runs k3s server with t3.medium instance
- **Agent(Worker) Node (k3s-agent)**: Deployed in the second private subnet, runs k3s agent with t3.small instance
- **Access**: Cluster accessible via bastion host and optionally from local machine

### Manual K3s Installation Steps

#### Step 1: Install K3s Master Node

1. SSH to the bastion host:
```bash
ssh -i your-key.pem ubuntu@<bastion-public-ip>
```

2. SSH to the k3s server (master) node (*.pem key should be uploaded on the bastion with right permissions):
```bash
ssh -i your-key.pem ubuntu@<k3s-server-private-ip>
```

3. Install k3s server:
```bash
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
```

4. Get the node token for worker nodes:
```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

5. Copy the kubeconfig file:
```bash
cp /etc/rancher/k3s/k3s.yaml ~/k3s.yaml
sudo chown ubuntu:ubuntu ~/k3s.yaml
```
6. Back to bastion host:
```bash
exit
```

7. Copy the k3s config from the server node to bastion:
```bash
# From bastion host
scp -i your-key.pem ubuntu@<k3s-server-private-ip>:~/k3s.yaml ~/k3s.yaml
```

8. Replace the server IP address in the k3s config:
```bash
# Replace the server IP in the config file to use the actual k3s server IP
sed -i 's/127\.0\.0\.1/<k3s-server-private-ip>/g' ~/k3s.yaml
```

9. Install kubectl on bastion host:
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to system path
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

10. Set up kubectl access:
```bash
echo 'export KUBECONFIG=~/k3s.yaml' >> ~/.bashrc
source ~/.bashrc
```

#### Step 2: Install K3s Worker Node

1. SSH to the k3s agent (worker) node from bastion host:
```bash
ssh -i your-key.pem ubuntu@<k3s-agent-private-ip>
```

2. Join the worker node to the cluster:
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://<k3s-server-private-ip>:6443 K3S_TOKEN=<node-token> sh -
```
<node-token> is from step 1.4

### Cluster Verification

From the bastion host (after kubectl installation), verify the cluster:

```bash
# Check cluster nodes (should show 2 nodes)
kubectl get nodes

# Check cluster info
kubectl cluster-info

# Check all resources
kubectl get all --all-namespaces
```

### Deploy Test Workload

Deploy the required nginx pod to verify the cluster:

```bash
# Deploy the test pod
kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml

# Verify pod is visible in all namespaces view
kubectl get all --all-namespaces
```

### Accessing K3s from Local Machine (Windows) (Additional Task)

#### SSH Tunnel Method

1. Copy the config from bastion to your local machine:

**Windows PowerShell:**
```powershell
# From your local machine (using scp if available, or WinSCP/FileZilla)
scp -i your-key.pem ubuntu@<bastion-public-ip>:~/k3s.yaml ./k3s-local.yaml
```

2. Set up SSH tunnel through bastion host:

**Windows PowerShell:**
```powershell
ssh -L 6443:<k3s-server-private-ip>:6443 -i your-key.pem ubuntu@<bastion-public-ip>
```

3. Edit the config file to use localhost:

**Windows PowerShell:**
```powershell
# Edit k3s-local.yaml and change server URL to use localhost for the tunnel
(Get-Content k3s-local.yaml) -replace '<k3s-server-private-ip>:6443', 'localhost:6443' | Set-Content k3s-local.yaml
```

4. Use kubectl locally:

**Windows PowerShell:**
```powershell
$env:KUBECONFIG = ".\k3s-local.yaml"
kubectl get nodes
```

### Required Security Group Rules for K3s

Your infrastructure uses the `inter-subnet` security group which allows all communication between subnets within the VPC. This enables k3s cluster communication including:

- **6443/tcp**: Kubernetes API server
- **10250/tcp**: Kubelet API  
- **8472/udp**: Flannel VXLAN (if using default CNI)
- **All other k3s [required ports](https://docs.k3s.io/installation/requirements)**

The `inter_subnet` security group is already configured to allow all traffic within the VPC CIDR (10.0.0.0/16), so no additional k3s-specific security group configuration is needed.

## Accessing Private Instances

To access instances in private subnets:

1. SSH to the bastion host:

```bash
ssh -i your-key.pem ubuntu@<bastion-public-ip>
```

2. From the bastion host, SSH to the private instance:

```bash
ssh -i your-key.pem ubuntu@<private-instance-ip>
```

## Security Considerations

- The bastion host security group allows SSH access only
- Private instances only allow SSH access from the bastion host
- The NAT Gateway provides secure outbound internet access for private subnets
- K3s cluster communication is secured within private subnets
- Inter-subnet security group allows communication between all the nodes (k3s nodes)

### Security Groups Configuration

Your infrastructure includes the following security groups:

1. **Bastion Security Group** (`main-vpc-bastion-sg`):
   - Allows SSH (port 22) from specified CIDR blocks
   - Allows all outbound traffic

2. **SSH from Bastion Security Group** (`main-vpc-ssh-from-bastion-sg`):
   - Allows SSH (port 22) only from the bastion host
   - Applied to all private instances (k3s nodes)

3. **Inter-Subnet Security Group** (`main-vpc-inter-subnet-sg`):
   - Allows ALL traffic within VPC CIDR (10.0.0.0/16)
   - Enables k3s cluster communication between nodes
   - Applied to all k3s nodes

4. **Web Security Group** (`main-vpc-web-sg`):
   - Allows HTTP (port 80) and HTTPS (port 443) from anywhere
   - Available for public-facing services if needed


## Cleanup

To destroy all resources created by this Terraform configuration:

```bash
terraform destroy
```

## GitHub Actions Required Secrets

To enable CI/CD with GitHub Actions, you must configure the following repository secrets:

- `EXTRA_BUCKET` — S3 bucket name for storing Terraform artifacts (not the state bucket)
- `TERRAFORM_STATE_BUCKET` — S3 bucket name for storing Terraform state
- `AWS_ACCOUNT_ID` — Your AWS account ID
- `EC2_KEY_NAME` — Name of the AWS EC2 key pair to use for SSH
- `ALLOWED_CIDR` — CIDR block allowed to access the bastion host (e.g., `1.2.3.4/32`)

All secrets can be set in your repository settings under **Settings → Secrets and variables → Actions**.

