REPO_ROOT := $(CURDIR)
SCRIPTS_DIR ?= $(CURDIR)/scripts
NETPERF_DIR ?= $(CURDIR)/netperf
KIND_KUBECONFIG ?= ${HOME}/.kube/kind

###############################################################################
# CI Bootstrap Related Targets ################################################
###############################################################################

.PHONY: setup-env
setup-env:
	${SCRIPTS_DIR}/setup-env.sh

.PHONY: teardown-env
teardown-env:
	kind delete cluster --name cluster1
	kind delete cluster --name cluster2

.PHONY: runNetperf
run-netperf:
	kubectl config use-context kind-cluster2 --kubeconfig ${KIND_KUBECONFIG}
	kubectl apply -f ${NETPERF_DIR}/k8s-netperf.yaml
	kubectl wait pods -l app=netperf-host --for=condition=Ready
	kubectl wait pods -l app=netperf-pod --for=condition=Ready
	perl -w ${NETPERF_DIR}/runNetPerfTest.pl --nobaseline 2>>${NETPERF_DIR}/out/cluster2-netperf-log.txt

.PHONY: cleanup-netperf
cleanup-netperf:
	kubectl config use-context kind-cluster2 --kubeconfig ${KIND_KUBECONFIG}
	kubectl delete -f ${NETPERF_DIR}/k8s-netperf.yaml --ignore-not-found
