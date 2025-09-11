# Openshift Cluster Config

This repo sets up OpenShift with Day 2 thingys via Red Hat OpenShift GitOps and ArgoCD


## Installing ArgoCD

First apply the `Subscription` manifest for the Red Hat OpenShift GitOps Operator

```shell
cat <<EOF | oc apply -f -
---
kind: Project
apiVersion: project.openshift.io/v1
metadata:
  name: openshift-gitops-operator
  labels:
    openshift.io/cluster-monitoring: 'true'
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-gitops-operator
  namespace: openshift-gitops-operator
spec:
  upgradeStrategy: Default
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
    operators.coreos.com/openshift-gitops-operator.openshift-gitops-operator: ''
  name: openshift-gitops-operator
  namespace: openshift-gitops-operator
spec:
  channel: latest
  installPlanApproval: Automatic
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
---
EOF
```

Wait for the pods to appear

```shell
echo -n "Still waiting" ; until [[ $(oc get pods -n openshift-gitops -o name  | wc -l) -ne 0 ]]; do echo -n "."; sleep 3; done; echo ""
```

Give the ArgoCD serviceAccount permission to admin the cluster

```shell
oc adm policy add-cluster-role-to-user cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
```

Wait for the deployment rollout

```shell
oc rollout status deploy/openshift-gitops-server -n openshift-gitops
```

To get the admin password

```shell
oc  get secret openshift-gitops-cluster -n openshift-gitops -ojsonpath='{.data.admin\.password}' | base64 -d ; echo
```

## Deploying this Repo

To configure your cluster to this repo run

```
oc apply -k https://github.com/ryan-highley/integration-dev-demo-cluster-config/cluster-config/config/overlays/default
```
