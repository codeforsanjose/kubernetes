resource "kubectl_manifest" "github-actions-cluster-role" {
  yaml_body = <<-YAML
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: github-actions
    rules:
      - apiGroups: [""]
        resources: ["namespaces"]
        verbs: ["list"]
  YAML
}

resource "kubectl_manifest" "github-actions-cluster-role-binding" {
  yaml_body = <<-YAML
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: github-actions
    subjects:
      - kind: User
        name: github-actions
        namespace: kube-system
        apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: github-actions
      apiGroup: rbac.authorization.k8s.io
  YAML
}
