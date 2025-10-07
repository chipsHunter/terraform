### Terraform conf for Yandex Cloud infrastructure

> [!TIP]
> before forking the project, write `$HOME/.terraformrc` file for [Terraform CLI](https://yandex.cloud/en/docs/tutorials/infrastructure-management/terraform-modules#configure-provider)

### Как запустить?
#### Проинициализируйте бэкенд для удаленного хранения состония

```bash
cd initialize_backend
terraform plan
terraform apply -auto-approve
cd ..
```
#### Поднимите инфраструктуру сети
```bash
cd main_logic
terraform plan
terraform apply -auto-approve
cd ..
```
В данной конфигурации кластер `k3s` поднят на инстансе в приватной сети, поэтому для его администрирования через **бастион хост** нужно:
* скопировать конфиг кластера себе ( и соответственно сконфигурировать его расположение через `var.kube_config`
```bash
scp -i <key_to_bastion> -J ubuntu@<public_nat_bastion_addr> ubuntu@<private_app_addr>
```
* прокинуть SSH-туннель для администрирования кластером со своего хоста
```bash
ssh -N -L 6443:<private_app_addr>:6443 ubuntu@<public_nat_bastion_addr> -i <key_to_bastion>
```
> [!NOTE]
> не закрывать это окно терминала, пока не закончите шаг 3

