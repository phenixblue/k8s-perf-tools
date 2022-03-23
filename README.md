# k8s-perf-tools

A collection of Kubernetes Performance Testing/Benchmarking Tools

## Environment Setup

```shell
$ export KUBECONFIG=$HOME/.kube/kind
$ make setup-env
```

## Netperf Setup

### Install required CPAN library

```shell
$ sudo cpan JSON::Parse
```
### Netperf

```shell
# Switch to the target
$ kubectl config use-context kind-cluster2 --kubeconfig $HOME/.kube/kind
# Deploy Netperf resourcesc
$ kubectl apply -f ./netperf/k8s-netperf.yaml
# Execute Netperf tests
$ ./netperf/runNetPerfTest.pl --nobaseline 2>>./netperf/out/cluster2-netperf-log.txt
# Cleanup Netperf resources
$ kubectl delete -f ./netperf/k8s-netperf.yaml
```