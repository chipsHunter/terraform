
resource "kubernetes_secret_v1" "backend_secrets" {
  metadata {
    name      = "backend-secrets"
    namespace = "default"
  }
  type = "Opaque"
  data = local.backend_env
}

resource "kubernetes_secret_v1" "ycr_secret" {
  metadata {
    name = "ycr-credentials"
  }
  type = "kubernetes.io/dockerconfigjson"

  data = {
    # ИСПРАВЛЕНО: Правильно формируем .dockerconfigjson
    ".dockerconfigjson" = jsonencode({
      auths = {
        "cr.yandex" = {
          # Используем одну и ту же переменную с токеном
          auth = base64encode("iam:${var.iam_token}")
        }
      }
    })
  }
}


# Разворачиваем Helm-чарт
resource "helm_release" "my_java_app" {
  name       = var.chart_repo_settings["main"].name
  chart      = var.chart_repo_settings["main"].chart
  version    = var.chart_repo_settings["main"].version
  namespace  = "default"
  repository = "oci://cr.yandex/${data.terraform_remote_state.infra.outputs.registry_id}"

  set = [
    {
      name  = "backend.existingSecretName"
      value = kubernetes_secret_v1.backend_secrets.metadata[0].name
    },
    {
      # Путь 'frontend.imagePullSecretsName' должен соответствовать вашему чарту
      name  = "frontend.imagePullSecretsName"
      value = kubernetes_secret_v1.ycr_secret.metadata[0].name
    },
    {
      # Путь 'backend.imagePullSecretsName' должен соответствовать вашему чарту
      name  = "backend.imagePullSecretsName"
      value = kubernetes_secret_v1.ycr_secret.metadata[0].name
    }
  ]
}
