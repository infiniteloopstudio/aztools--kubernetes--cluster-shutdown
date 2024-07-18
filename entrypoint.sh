#!/bin/bash
#######################################################################################################################################
# Constants
#######################################################################################################################################

_error="\e[0;31m##[error]"
_warning="\e[0;33m##[warning]"
_command="\e[0;34m##[command]"
_debug="\e[0;35m##[debug]"
_0="\e[0m"

#######################################################################################################################################
# Functions
#######################################################################################################################################

function check_env() {
    if [[ -z "$CLUSTER_NAME" ]]; then echo -e "${_error}Missing required environment variable CLUSTER_NAME"; exit 1; fi
    if [[ -z "$CLUSTER_RESOURCE_GROUP" ]]; then echo -e "${_error}Missing required environment variable CLUSTER_RESOURCE_GROUP"; exit 1; fi
    if [[ -z "$CLUSTER_SUBSCRIPTION_ID" ]]; then echo -e "${_error}Missing required environment variable CLUSTER_SUBSCRIPTION_ID"; exit 1; fi
}

function get_cluster_power_state() {
    echo -e "${_command}az aks show -n $CLUSTER_NAME -g $CLUSTER_RESOURCE_GROUP --query \"powerState.code\" -o tsv" >&2
    local power_state=$(az aks show -n $CLUSTER_NAME -g $CLUSTER_RESOURCE_GROUP --query "powerState.code" -o tsv)
    echo -e "${_debug}power_state=$power_state" >&2
    echo $power_state
}

function login_to_azure() {
    echo -e "${_command}az login -p *** -u *** --allow-no-subscriptions --service-principal --tenant ***"
    az login -p "$AZURE_CLIENT_SECRET" -u $AZURE_CLIENT_ID --allow-no-subscriptions --service-principal --tenant $AZURE_TENANT_ID > /dev/null 2>&1
    if [ $? -ne 0 ]; then echo -e "${_error}Azure login failed"; exit 1; fi 
}

function print_banner() {
    echo "########################################################"
    echo "# Azure Kubernetes Tools - Cluster Shutdown"
    echo "#"
    echo "# Shut down an AKS cluster."
    echo "#"
    echo "# Author: Joshua Sprague"
    echo "########################################################"
}

function print_debug_info() {
    echo
    echo -e "${_debug}AZURE_CLIENT_ID=${AZURE_CLIENT_ID:0:5}*****"
    echo -e "${_debug}AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET:0:3}*****"
    echo -e "${_debug}AZURE_TENANT_ID=${AZURE_TENANT_ID:0:5}*****"
    echo -e "${_debug}CLUSTER_NAME=$CLUSTER_NAME"
    echo -e "${_debug}CLUSTER_RESOURCE_GROUP=$CLUSTER_RESOURCE_GROUP"
    echo -e "${_debug}CLUSTER_SUBSCRIPTION_ID=${CLUSTER_SUBSCRIPTION_ID:0:5}*****"
}

function set_subscription() {
    echo -e "${_command}az account set -s ***"
    az account set -s $CLUSTER_SUBSCRIPTION_ID;
    if [ $? -ne 0 ]; then echo -e "${_error}Failed to set subscription. Ensure the service principal has the appropriate permissions to access the AKS cluster's subscription"; exit 1; fi
}

function stop_cluster() {
    echo -e "${_0}Executing cluster stop action on $CLUSTER_NAME..."
    echo -e "${_command}az aks stop -n $CLUSTER_NAME -g $CLUSTER_RESOURCE_GROUP --no-wait"
    az aks stop -n $CLUSTER_NAME -g $CLUSTER_RESOURCE_GROUP --no-wait
    echo -e "${_0}"
    echo "~Executed cluster stop action on $CLUSTER_NAME"
}

#######################################################################################################################################
# Main Script Body
#######################################################################################################################################

print_banner
check_env
print_debug_info
login_to_azure
set_subscription

power_state=$(get_cluster_power_state)

if [[ "$power_state" == "Running" ]]; then
	stop_cluster
    echo -e "${_0}\nDone - Cluster is shutting down"
elif [[ "$power_state" == "Stopped" ]]; then
    echo -e "${_0}\nDone - Cluster is already stopped"
else
    echo -e "${_error}Unexpected cluster power state: $power_state"
    exit 1
fi
