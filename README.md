# mlops-toolkit

## Development guide

### Prerequisite

1. [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) installed and configured for your cluster

#### Set up the mlops-data-fetcher. 

```
cd mlops-toolkit
make proto
```

#### Download client certificates for storage from the k9s cluster you want to connect to. 

1. You should have configured your kubectl to connect to the k8s cluster. 
2. Make sure you have selected the correct cluster
```
kubectl config set current-context <name-of-oyour-cluster>
```
3. Run the [download_certs.sh](./scripts/download_certs.sh) script.
```
./scripts/download_certs.sh [MLOPS_PREFIX] [MLOPS_K8_NAMESPACE]
```

ex: For xy-test platform instances

```
./scripts/download_certs.sh mlops default 
```
Verify that after running the script, three files named `ca`, `certificate`, and `key` have been downloaded into the `certs` directory from the specified cluster.

#### Set environment variables. 

1. You have to start kubectl port-forwarding for storage. 
```bash
kubectl port-forward service/<mlops-storage-service-name> 9999:9999
```
2. Then set the following envs for the app. 

```
export STORAGE_URL=<storage-url-with-port>
```

ex: 

```
export STORAGE_URL=localhost:9999
```

#### Run the app 

```
make run
```
