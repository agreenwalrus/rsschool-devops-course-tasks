# Task 4: Jenkins Installation and Configuration

## Setup

### 1. Setup Minikube

```powershell
# Install Minikube
winget install Kubernetes.minikube

# Verify installation
minikube version
```

**Expected output:** `minikube version: v1.x.x`

### 2. Setup kubectl

```powershell
# Install kubectl
winget install -e --id Kubernetes.kubectl

# Verify installation
kubectl version --client
```

**Expected output:** Should display client version information.

### 3. Setup Helm

```powershell
# Install Helm
winget install Helm.Helm

# Verify installation
helm version
```

**Expected output:** Should display Helm version information.

### 4. Setup Docker (if not already installed)

Docker is required as the container runtime for Minikube.

```powershell
# Install Docker Desktop
winget install Docker.DockerDesktop
```

**Note:** After installation, restart your computer and ensure Docker Desktop is running before proceeding.

## Task Instructions:

### 1. Start Minikube

Start your local Kubernetes cluster with Docker as the driver.

```powershell
# Start Minikube with Docker driver
minikube start --driver=docker

# Optional: Set Docker as default driver for future starts
minikube config set driver docker
```

**Expected output:** Should show successful cluster startup messages.

### 2. Verify Cluster Status

Confirm that your Kubernetes cluster is running properly.

```powershell
# Check cluster information
kubectl cluster-info

# Verify nodes are ready
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system
```

**Expected output:** 
- Cluster info should show running master
- Node should be in "Ready" status
- All system pods should be "Running"

### 3. Helm Verification

Test Helm functionality by deploying a sample application.

```powershell
# Add Bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# Install test nginx
helm install test-nginx bitnami/nginx

# Wait for pod to be ready (may take a few minutes)
kubectl get pods --watch

# Once running, clean up the test
helm uninstall test-nginx
```

**Expected output:** Pod should transition from "Pending" → "ContainerCreating" → "Running"

### 4. Install Jenkins

Deploy Jenkins using Helm with persistent storage.

```powershell
# Add Jenkins Helm repository
helm repo add jenkins https://charts.jenkins.io

# Update repositories
helm repo update

# Create dedicated namespace for Jenkins
kubectl create namespace jenkins

# Install Jenkins with default configuration
helm install jenkins jenkins/jenkins --namespace jenkins

# Wait for Jenkins pod to be ready (this may take 5-10 minutes)
kubectl get pods -n jenkins --watch
```

**Note:** The first time Jenkins starts, it needs to download the image and initialize, which can take several minutes.

#### 4.1. Verify Jenkins Deployment

Check that Jenkins components are properly deployed and running.

```powershell
# Check persistent volume claim status
kubectl get pvc -n jenkins

# Verify Jenkins pod is running
kubectl get pods -n jenkins

# Check Jenkins service
kubectl get svc -n jenkins
```

**Expected output:** 
- PVC should be "Bound"
- Pod should be "Running" 
- Service should show ClusterIP assigned

#### 4.2. Monitor Jenkins Startup (Optional)

If Jenkins is taking time to start, monitor the logs to track progress.

```powershell
# Get container logs (useful for troubleshooting)
kubectl logs jenkins-0 -n jenkins -c jenkins
```

**Note:** Use `Ctrl+C` to stop following the logs.

### 5. Access Jenkins

#### 5.1. Retrieve Admin Password

Get the auto-generated admin password for first-time login.

```powershell
# Get the admin password
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password
```

**Important:** Copy this password - you'll need it for login.

#### 5.2. Setup Port Forwarding

Forward the Jenkins service port to your local machine.

```powershell
# Forward Jenkins port to localhost
kubectl --namespace jenkins port-forward svc/jenkins 8080:8080
```

**Note:** Keep this terminal window open. The port forwarding will stop if you close it.

#### 5.3. Login to Jenkins

1. Open your web browser and navigate to: [http://localhost:8080](http://localhost:8080)
2. Login credentials:
   - **Username:** `admin`
   - **Password:** Use the password from step 5.1

**Expected result:** You should see the Jenkins dashboard after successful login.

### 6. Create Your First Jenkins Job

#### 6.1. Create a New Project

1. Click the **"New Item"** button on the Jenkins dashboard
2. Enter a project name (e.g., "hello-world-job")
3. Select **"Freestyle project"**
4. Click **"OK"**

#### 6.2. Configure the Build

1. In the project configuration page, scroll to the **"Build"** section
2. Click **"Add build step"** → **"Execute shell"**
3. Enter the following command:

```bash
echo "Hello world"
```

4. Click **"Save"**

### 7. Execute and Monitor Your Job

#### 7.1. Trigger a Build

1. On your project page, click **"Build Now"**
2. Watch the build progress in the **"Build History"** section
3. Click on the build number (e.g., "#1") to view details

#### 7.2. View Build Results

1. In the build details page, click **"Console Output"**
2. Review the execution logs
3. Verify that your echo statements appear in the output

**Expected output:** You should see your "Hello World" message, build information, and timestamp.

## Cleanup 

```powershell
# Stop port forwarding (Ctrl+C in the forwarding terminal)

# Uninstall Jenkins
helm uninstall jenkins -n jenkins

# Delete the namespace
kubectl delete namespace jenkins

# Stop Minikube
minikube stop

# Delete Minikube cluster (optional - removes all data)
minikube delete
```

