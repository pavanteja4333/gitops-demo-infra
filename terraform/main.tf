resource "kubernetes_namespace" "demo_app" {
  metadata {
    name = "demo-app"
    labels = {
      environment = "development"
      project     = "gitops-demo"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      project = "gitops-demo"
    }
  }
}

# Deploy ArgoCD via Helm Chart
resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "6.7.18" # Stable version of ArgoCD helm chart
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  # Disable SSL verification for dashboard access (convenient for local dev over HTTP)
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  # Set Service Type to ClusterIP (access dashboard via Port-Forwarding)
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Speed up startup for local testing
  set {
    name  = "controller.replicas"
    value = "1"
  }
  set {
    name  = "repoServer.replicas"
    value = "1"
  }
}
