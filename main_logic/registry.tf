resource "yandex_container_registry" "default" {
  name = var.registry_name
}

/*   вообще по-хорошему сделать отдельную роль для пула образов
     по принципу наименьших привилегий
     но нам таких прав никто не дал
     
resource "yandex_iam_service_account" "k3s_puller" {
  name = "k3s-image-puller"
}

resource "yandex_container_registry_iam_binding" "puller_binding" {
  registry_id = yandex_container_registry.default.id
  role        = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.k3s_puller.id}",
  ]
}
*/
