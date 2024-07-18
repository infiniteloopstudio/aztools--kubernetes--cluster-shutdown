# Azure Kubernetes Cluster Shutdown Job

Containerized job for shutting down an AKS cluster.

### ⚙️ Run

```sh {"id":"01J2Z49C07HA390ND9QGS8F37A","promptEnv":"false","terminalRows":"25"}
docker run --rm \
    -e AZURE_CLIENT_ID=__APPREG_CLIENT_ID__ \
    -e "AZURE_CLIENT_SECRET=__APPREG_CLIENT_SECRET__" \
    -e AZURE_TENANT_ID=__TENANT_ID__ \
    -e CLUSTER_NAME=__CLUSTER_NAME__ \
    -e CLUSTER_RESOURCE_GROUP=__CLUSTER_RESOURCE_GROUP__ \
    -e CLUSTER_SUBSCRIPTION_ID=__CLUSTER_SUBSCRIPTION_ID__ \
    "infiniteloopstudio/aztools-kubernetes-clustershutdown:latest"
```

### 🚀 Deploy

To execute this job within our Azure-hosted environment, we can deploy it as a job to any Azure Container App Environment of our choosing.

#### Deploy Azure Container Instance

***Create the Container Job***

```sh {"id":"01J2Z49C07HA390ND9QJB0P2QV"}
# Job Configuration
job_subscription_id=__JOB_SUBSCRIPTION_ID__
job_resource_group=__JOB_RESOURCE_GROUP__
job_capps_environment=__JOB_CONTAINER_APPS_ENV__
job_cron_expression="0 17 * * *"

# Runtime Configuration
AZURE_CLIENT_ID=__APPREG_CLIENT_ID__
AZURE_CLIENT_SECRET=__APPREG_CLIENT_SECRET__
AZURE_TENANT_ID=__TENANT_ID__
cluster_name=__CLUSTER_NAME__
cluster_resource_group=__CLUSTER_RESOURCE_GROUP__
cluster_subscription_id=__CLUSTER_SUBSCRIPTION_ID__

az account set -s $job_subscription_id

az containerapp job create \
  --name cluster-shutdown \
  --resource-group $job_resource_group \
  --environment $job_capps_environment \
  --cpu "0.25" \
  --cron-expression "$job_cron_expression" \
  --env-vars \
      AZURE_CLIENT_ID=$AZURE_CLIENT_ID \
      "AZURE_CLIENT_SECRET=secretref:client-secret" \
      AZURE_TENANT_ID=$AZURE_TENANT_ID \
      CLUSTER_NAME=$cluster_name \
      CLUSTER_RESOURCE_GROUP=$cluster_resource_group \
      CLUSTER_SUBSCRIPTION_ID=$cluster_subscription_id \
  --image infiniteloopstudio/aztools-kubernetes-clustershutdown \
  --memory "0.5Gi" \
  --parallelism 1 \
  --replica-timeout 60 \
  --replica-retry-limit 1 \
  --replica-completion-count 1 \
  --trigger-type Schedule \
  --secrets "client-secret=$AZURE_CLIENT_SECRET"
```