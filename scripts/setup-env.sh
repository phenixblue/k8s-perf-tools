#!/usr/bin/env bash

##############################################################
#### CONSTANTS, VARIBALES, ETC. ##############################
##############################################################

TOOL_LIST="docker helm kubectl kind"
DOCKER_CMD="docker"
HELM_CMD="helm"
KUBECTL_CMD="kubectl"
KIND_CMD="kind"
KIND_KUBECONFIG="${HOME}/.kube/kind"
CILIUM_VERSION="1.11.2"
CILIUM_IMAGE="quay.io/cilium/cilium:v${CILIUM_VERSION}"

##############################################################
#### FUNCTIONS ###############################################
##############################################################

# Check for required tools
tools::check::prereqs() {
    for tool in ${TOOL_LIST}; do
        if ! type "${tool}"; then
            echo "[ERROR]: The ${tool} tool was not found Please install and try again"
            exit 1
        fi
    done

}

# Setup Cilium Helm Chart Repo
cilium::setup::helm() {

    ${HELM_CMD} repo add cilium https://helm.cilium.io/

}

kind::setup::prereqs() {

    cilium::setup::helm

}

# Preload Cilium Images to nodes
# arg1 = Cluster Name
# arg2 = Full Image Reference (ie. registry + project + image + tag)
kind::load::image() {

    local cluster_name
    local image_reference

    cluster_name="${1}"
    image_reference="${2}"

    # Pull image locally
    ${DOCKER_CMD} pull "${image_reference}"

    # Load image to target KinD cluster nodes
    ${KIND_CMD} load docker-image --name "${cluster_name}" "${image_reference}"

}

# Install Cilium with Default settings
# arg1 = Cluster Name
cilium::install::defaults() {

    local cluster_name

    cluster_name="${1}"

    helm install cilium cilium/cilium --version "${CILIUM_VERSION}" \
   --kubeconfig "${KIND_KUBECONFIG}" --kube-context "kind-${cluster_name}" \
   --namespace kube-system \
   --set kubeProxyReplacement=partial \
   --set hostServices.enabled=false \
   --set externalIPs.enabled=true \
   --set nodePort.enabled=true \
   --set hostPort.enabled=true \
   --set bpf.masquerade=false \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

}

# Install Cilium with partial kube-proxy replacement enabled
# arg1 = Cluster Name
cilium::install::kpr() {

    local cluster_name

    cluster_name="${1}"

    helm install cilium cilium/cilium --version "${CILIUM_VERSION}" \
   --kubeconfig "${KIND_KUBECONFIG}" --kube-context "kind-${cluster_name}" \
   --namespace kube-system \
   --set kubeProxyReplacement=strict \
   --set k8sServiceHost="${cluster_name}-control-plane" \
   --set k8sServicePort=6443 \
   --set loadBalancer.serviceTopology=true \
   --set hostServices.enabled=false \
   --set externalIPs.enabled=true \
   --set nodePort.enabled=true \
   --set hostPort.enabled=true \
   --set bpf.masquerade=false \
   --set image.pullPolicy=IfNotPresent \
   --set ipam.mode=kubernetes

}

# Install and configure Cilium on a given cluster
# arg1 = KPR enabled true/false
# arg2 = cluster name
kind::setup::cilium() {

    local cluster_name
    local kpr_enabled

    cluster_name="${1}"
    kpr_enabled="${2}"

    kind::load::image "${cluster_name}" "${CILIUM_IMAGE}"

    if [ "${kpr_enabled}" == "true" ]; then
        cilium::install::kpr "${cluster_name}"
    else
        cilium::install::defaults "${cluster_name}"
    fi

}


#### Build KinD Clusters

kind::build::clusters() {

    # Build standard cluster with KinDNet CNI
    ${KIND_CMD} create cluster --name cluster1 --config=kind/kind-kindnet.yaml --kubeconfig="${KIND_KUBECONFIG}"
    # Build cluster with Cilium CNI and default options
    ${KIND_CMD} create cluster --name cluster2 --config=kind/kind-cilium-defaults.yaml --kubeconfig="${KIND_KUBECONFIG}"
    # Build cluster with Cilium CNI and KubeProxy replacement enabled
    ${KIND_CMD} create cluster --name cluster3 --config=kind/kind-cilium-kpr.yaml --kubeconfig="${KIND_KUBECONFIG}" 

}

main() {

    tools::check::prereqs
    kind::setup::prereqs
    kind::build::clusters
    kind::setup::cilium "cluster2" "false"
    kind::setup::cilium "cluster3" "true"

}

##############################################################
#### MAIN SCRIPT #############################################
##############################################################

main