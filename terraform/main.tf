terraform {
  # cloud {
  #   organization = "PureHuman"
  #   workspaces {
  #     name = "highway-dev"
  #   }
  # }
}


provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

resource "kubernetes_namespace_v1" "highway" {
  metadata {
    name = "highway"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set = [{
    name  = "server.service.type"
    value = "NodePort"
  }]
}

resource "helm_release" "argocd_app" {
  name       = "argocd-app"
  chart      = "../charts/argocd-app"
  namespace  = "argocd"
  depends_on = [helm_release.argocd]
}
