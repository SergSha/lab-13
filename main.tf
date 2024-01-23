locals {
  k8s_version = "1.25"
  sa_name     = "sergsha"
  vpc_name    = "labnet"

  folders = {
    "labfolder" = {}
  }

  #subnets = {
  #  "lab-subnet" = {
  #    v4_cidr_blocks = ["10.10.10.0/24"]
  #  }
  subnet_cidrs = ["10.1.0.0/16"]
  subnet_name  = "labsubnet"
}

resource "yandex_resourcemanager_folder" "folders" {
  for_each = local.folders
  name     = each.key
  cloud_id = var.cloud_id
}

resource "yandex_kubernetes_cluster" "k8s-lab" {
  name        = "k8s-lab"
  description = "My Kubernetes Cluster"
  folder_id   = yandex_resourcemanager_folder.folders["labfolder"].id
  network_id  = yandex_vpc_network.labnet.id
  master {
    version = local.k8s_version
    zonal {
      zone      = yandex_vpc_subnet.labsubnet.zone
      subnet_id = yandex_vpc_subnet.labsubnet.id
    }
    public_ip = true
    #security_group_ids = [yandex_vpc_security_group.k8s-public-services.id]
  }
  service_account_id      = yandex_iam_service_account.sergsha.id
  node_service_account_id = yandex_iam_service_account.sergsha.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.editor,
    #yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    #yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    #yandex_resourcemanager_folder_iam_member.images-puller,
  ]
  #kms_provider {
  #  key_id = yandex_kms_symmetric_key.kms-key.id
  #}
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl config delete-context yc-k8s-lab
      kubectl config delete-cluster yc-managed-k8s-${self.id}
      kubectl config delete-user yc-managed-k8s-${self.id}
    EOT
  }
  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials ${self.id} --external"
  }
}

resource "yandex_vpc_network" "labnet" {
  name      = local.vpc_name
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
}

resource "yandex_vpc_subnet" "labsubnet" {
  name           = local.subnet_name
  folder_id      = yandex_resourcemanager_folder.folders["labfolder"].id
  v4_cidr_blocks = local.subnet_cidrs
  zone           = var.zone
  network_id     = yandex_vpc_network.labnet.id
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name      = "default-gateway"
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "main-route-table"
  folder_id  = yandex_resourcemanager_folder.folders["labfolder"].id
  network_id = yandex_vpc_network.labnet.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_iam_service_account" "sergsha" {
  name        = local.sa_name
  description = "K8S zonal service account"
  folder_id  = yandex_resourcemanager_folder.folders["labfolder"].id
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
  #folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sergsha.id}"
}
/*
resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.sergsha.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.sergsha.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.sergsha.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "viewer" {
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
  role      = "viewer"
  member    = "serviceAccount:${yandex_iam_service_account.sergsha.id}"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}
*/
resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-services"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  folder_id = yandex_resourcemanager_folder.folders["labfolder"].id
  network_id  = yandex_vpc_network.labnet.id
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера Managed Service for Kubernetes и сервисов."
    v4_cidr_blocks    = concat(yandex_vpc_subnet.labsubnet.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает входящий трафик из интернета на 80 порт для доступа к веб-странице WordPress. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 80
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает входящий трафик из интернета на 443 порт для доступа к веб-странице WordPress. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 443
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}

resource "yandex_kubernetes_node_group" "lab_node_group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-lab.id}"
  name        = "lab-node-group"
  description = "description"
  version     = local.k8s_version

  labels = {
    "key" = "value"
  }

  instance_template {
    platform_id = "standard-v3"

    network_interface {
      nat                = false
      subnet_ids         = ["${yandex_vpc_subnet.labsubnet.id}"]
    }

    resources {
      memory        = 2
      cores         = 2
      core_fraction = 50
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    #fixed_scale {
    #  size = 3
    #}
    auto_scale {
      min     = 3
      max     = 5
      initial = 3
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "21:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "21:00"
      duration   = "4h30m"
    }
  }
}