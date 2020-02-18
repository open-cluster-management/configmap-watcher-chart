# Cloud Private Config Map Watcher

## Introduction
This chart deploys the Config Map Watcher service restarts pods when the config map it needs to watch changes.

## How to use Configmap-Watcher
This readme contains the details needed to use the configmap-watcher.

## Prerequisites
* Kubernetes version 1.13 or above
* Helm version 2.9 or above

### PodSecurityPolicy Requirements
The predefined `PodSecurityPolicy` name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this `PodSecurityPolicy` you can proceed to install the chart.

This chart also defines a custom `PodSecurityPolicy` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `PodSecurityPolicy` using the management console.

- From the user interface, you can copy and paste the following snippets to enable the custom `PodSecurityPolicy` into the create resource section
  - Custom PodSecurityPolicy definition:
    ```yaml
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive,
          requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
        apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-restricted-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      volumes:
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-restricted-psp-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-restricted-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

## Resources Required
* None

## Installing the Chart
One instance of the configmap-watcher chart comes installed. If it is not installed, then run the following `helm` command to install it:

```bash
helm install -n configmap-watcher --namespace kube-system <path to chart>/configmap-watcher --tls
```

You can also install it from the management console by navigating to either the Helm Releases page or the Catalog page and searching for `configmap-watcher`. 

## Configuration
Changes to configuration can be made in the values.yaml file or in a values-override.yaml where it will override the values in values.yaml.

To install or upgrade the chart with a values-override.yaml, the `helm` command would look like this:
```bash
helm upgrade configmap-watcher --force -f values-override.yaml configmap-watcher --tls
```

## Red Hat OpenShift SecurityContextConstraints Requirements
The Certificate manager webhook service runs using the [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) security context.

## Limitations
* There can only be a single deployment of the config map watcher service in a cluster, and it is installed by default.
