# Hashicorp Vault + K8s

---

## Что с нами будет?
* Ветка для работы: `kubernetes-vault`
* В ходе работы мы:
    * установим кластер vault в kubernetes
    * научимся создавать секреты и политики
    * настроим авторизацию в vault через kubernetes sa 
    * сделаем под с контейнером nginx, в который прокинем секреты из vault через consul-template

---
## Подготовка
* должен быть запущенный kubernetes кластер
* Все созданные в процесс ДЗ файлы должны быть в репозитории

* вспомогательные ссылки
    * [vault](https://learn.hashicorp.com/vault/identity-access-management/vault-agent-k8s#step-1-create-a-service-account)
    * [vault-guides](https://github.com/hashicorp/vault-guides.git)
* лейбл homework-11
* юзернейм для assignee erlong15

---

## Инсталляция hashicorp vault  HA в k8s

 * склонируем репозиторий consul (необходимо минимум 3 ноды)

 ```bash
 git clone https://github.com/hashicorp/consul-helm.git
 ```

 * Так как немного устарело, поэтому в файле ./consul-helm/templates/server-disruptionbudget.yaml подредактировал строку

 ```yaml
 apiVersion: policy/v1
 ```

 ```bash
 helm install consul ./consul-helm
 ```
 
 * склонируем репозиторий vault
 
 ```
 git clone https://github.com/hashicorp/vault-helm.git
 ```
---
 
## Отредактируем параметры установки в values.yaml
 
 ```yaml
   standalone:
    enabled: false
  ....
  ha:
    enabled: true
    raft:
      enabled: true
  ...
ui:
  enabled: true
  serviceType: "ClusterIP"
```

---

## Установим vault 


 ```bash
 helm install vault ./vault-helm/
 helm status vault
 kubectl logs vault-0
```
* обратите внимание на статус подов vault
* вывод  helm status vault - добавьте в README.md

```
[user@rocky9 lab-13]$ helm status vault
NAME: vault
LAST DEPLOYED: Thu Jan 11 21:36:12 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://developer.hashicorp.com/vault/docs


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get manifest vault
[user@rocky9 lab-13]$ 
```

```
[user@rocky9 lab-13]$ kubectl logs vault-0
==> Vault server configuration:

Administrative Namespace: 
             Api Address: http://10.244.0.4:8200
                     Cgo: disabled
         Cluster Address: https://vault-0.vault-internal:8201
   Environment Variables: GODEBUG, HOME, HOSTNAME, HOST_IP, KUBERNETES_PORT, KUBERNETES_PORT_443_TCP, KUBERNETES_PORT_443_TCP_ADDR, KUBERNETES_PORT_443_TCP_PORT, KUBERNETES_PORT_443_TCP_PROTO, KUBERNETES_SERVICE_HOST, KUBERNETES_SERVICE_PORT, KUBERNETES_SERVICE_PORT_HTTPS, NAME, PATH, POD_IP, PWD, SHLVL, SKIP_CHOWN, SKIP_SETCAP, VAULT_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO, VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS, VAULT_API_ADDR, VAULT_CLUSTER_ADDR, VAULT_K8S_NAMESPACE, VAULT_K8S_POD_NAME, VAULT_PORT, VAULT_PORT_8200_TCP, VAULT_PORT_8200_TCP_ADDR, VAULT_PORT_8200_TCP_PORT, VAULT_PORT_8200_TCP_PROTO, VAULT_PORT_8201_TCP, VAULT_PORT_8201_TCP_ADDR, VAULT_PORT_8201_TCP_PORT, VAULT_PORT_8201_TCP_PROTO, VAULT_SERVICE_HOST, VAULT_SERVICE_PORT, VAULT_SERVICE_PORT_HTTP, VAULT_SERVICE_PORT_HTTPS_INTERNAL, VERSION
              Go Version: go1.21.3
              Listener 1: tcp (addr: "[::]:8200", cluster address: "[::]:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: 
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: file
                 Version: Vault v1.15.2, built 2023-11-06T11:33:28Z
             Version Sha: cf1b5cafa047bc8e4a3f93444fcb4011593b92cb

==> Vault server started! Log data will stream in below:

2024-01-11T18:36:46.994Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2024-01-11T18:36:46.995Z [INFO]  incrementing seal generation: generation=1
2024-01-11T18:36:46.996Z [INFO]  core: Initializing version history cache for core
2024-01-11T18:36:46.996Z [INFO]  events: Starting event system
2024-01-11T18:36:55.129Z [INFO]  core: security barrier not initialized
2024-01-11T18:36:55.129Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:00.251Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:00.251Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:05.135Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:05.136Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:10.205Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:10.205Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:15.134Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:15.135Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:20.105Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:20.105Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:25.179Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:25.179Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:30.136Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:30.137Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:35.164Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:35.164Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:40.116Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:40.116Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:45.157Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:45.157Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:50.119Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:50.119Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:51.790Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:51.790Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:37:55.228Z [INFO]  core: security barrier not initialized
2024-01-11T18:37:55.228Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:00.106Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:00.106Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:05.127Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:05.128Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:10.161Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:10.161Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:15.238Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:15.238Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:20.131Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:20.131Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:25.133Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:25.133Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:30.167Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:30.167Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:35.135Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:35.135Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:40.137Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:40.137Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:45.117Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:45.117Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:50.110Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:50.110Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:54.772Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:54.772Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:38:55.124Z [INFO]  core: security barrier not initialized
2024-01-11T18:38:55.124Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:00.183Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:00.183Z [INFO]  core: seal configuration missing, not initialized
[user@rocky9 lab-13]$ 
```



---

## Инициализируем vault

* проведите инициализацию черерз любой под vault'а
```kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator init --key-shares=5 --key-threshold=3
Unseal Key 1: N8ZVIXld25WviRoLUZp+IeutwBFV3sgD8H+LRhxnJVbe
Unseal Key 2: Hw83M4i+wCkbUsXrizvKM5NP9bHUb9Px04vuHVadYmUZ
Unseal Key 3: 3vF+dmsIQqLJzKkwPgiXgKp0x9RF51dJt1xNNHbIWpkV
Unseal Key 4: mbFJZmzrLjw6lhY1asKVJaklBGlLSZUBqtx67W42q0TR
Unseal Key 5: u3LuFcH+jRMmwjui8N8wXV4/2nzTx3gm7ckIbowS7Dpk

Initial Root Token: hvs.oen1aEGBLNV3VdnBqQwRwXQY

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 3 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
[user@rocky9 lab-13]$
```

* сохраните ключи, полученные при инициализации
```
Unseal Key 1: N8ZVIXld25WviRoLUZp+IeutwBFV3sgD8H+LRhxnJVbe
Unseal Key 2: Hw83M4i+wCkbUsXrizvKM5NP9bHUb9Px04vuHVadYmUZ
Unseal Key 3: 3vF+dmsIQqLJzKkwPgiXgKp0x9RF51dJt1xNNHbIWpkV
Unseal Key 4: mbFJZmzrLjw6lhY1asKVJaklBGlLSZUBqtx67W42q0TR
Unseal Key 5: u3LuFcH+jRMmwjui8N8wXV4/2nzTx3gm7ckIbowS7Dpk

Initial Root Token: hvs.oen1aEGBLNV3VdnBqQwRwXQY
```
* вывод добавьте в README.md

* 🐍 поэкспериментируйте с разными значениями --key-shares --key-threshold

---

## Проверим состояние vault'а


```kubectl logs vault-0```

```
[user@rocky9 lab-13]$ kubectl logs vault-0
==> Vault server configuration:

Administrative Namespace: 
             Api Address: http://10.112.128.15:8200
                     Cgo: disabled
         Cluster Address: https://vault-0.vault-internal:8201
   Environment Variables: CONSUL_CONSUL_DNS_PORT, CONSUL_CONSUL_DNS_PORT_53_TCP, CONSUL_CONSUL_DNS_PORT_53_TCP_ADDR, CONSUL_CONSUL_DNS_PORT_53_TCP_PORT, CONSUL_CONSUL_DNS_PORT_53_TCP_PROTO, CONSUL_CONSUL_DNS_PORT_53_UDP, CONSUL_CONSUL_DNS_PORT_53_UDP_ADDR, CONSUL_CONSUL_DNS_PORT_53_UDP_PORT, CONSUL_CONSUL_DNS_PORT_53_UDP_PROTO, CONSUL_CONSUL_DNS_SERVICE_HOST, CONSUL_CONSUL_DNS_SERVICE_PORT, CONSUL_CONSUL_DNS_SERVICE_PORT_DNS_TCP, CONSUL_CONSUL_DNS_SERVICE_PORT_DNS_UDP, CONSUL_CONSUL_UI_PORT, CONSUL_CONSUL_UI_PORT_80_TCP, CONSUL_CONSUL_UI_PORT_80_TCP_ADDR, CONSUL_CONSUL_UI_PORT_80_TCP_PORT, CONSUL_CONSUL_UI_PORT_80_TCP_PROTO, CONSUL_CONSUL_UI_SERVICE_HOST, CONSUL_CONSUL_UI_SERVICE_PORT, CONSUL_CONSUL_UI_SERVICE_PORT_HTTP, GODEBUG, HOME, HOSTNAME, HOST_IP, KUBERNETES_PORT, KUBERNETES_PORT_443_TCP, KUBERNETES_PORT_443_TCP_ADDR, KUBERNETES_PORT_443_TCP_PORT, KUBERNETES_PORT_443_TCP_PROTO, KUBERNETES_SERVICE_HOST, KUBERNETES_SERVICE_PORT, KUBERNETES_SERVICE_PORT_HTTPS, NAME, PATH, POD_IP, PWD, SHLVL, SKIP_CHOWN, SKIP_SETCAP, VAULT_ACTIVE_PORT, VAULT_ACTIVE_PORT_8200_TCP, VAULT_ACTIVE_PORT_8200_TCP_ADDR, VAULT_ACTIVE_PORT_8200_TCP_PORT, VAULT_ACTIVE_PORT_8200_TCP_PROTO, VAULT_ACTIVE_PORT_8201_TCP, VAULT_ACTIVE_PORT_8201_TCP_ADDR, VAULT_ACTIVE_PORT_8201_TCP_PORT, VAULT_ACTIVE_PORT_8201_TCP_PROTO, VAULT_ACTIVE_SERVICE_HOST, VAULT_ACTIVE_SERVICE_PORT, VAULT_ACTIVE_SERVICE_PORT_HTTP, VAULT_ACTIVE_SERVICE_PORT_HTTPS_INTERNAL, VAULT_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO, VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS, VAULT_API_ADDR, VAULT_CLUSTER_ADDR, VAULT_K8S_NAMESPACE, VAULT_K8S_POD_NAME, VAULT_PORT, VAULT_PORT_8200_TCP, VAULT_PORT_8200_TCP_ADDR, VAULT_PORT_8200_TCP_PORT, VAULT_PORT_8200_TCP_PROTO, VAULT_PORT_8201_TCP, VAULT_PORT_8201_TCP_ADDR, VAULT_PORT_8201_TCP_PORT, VAULT_PORT_8201_TCP_PROTO, VAULT_SERVICE_HOST, VAULT_SERVICE_PORT, VAULT_SERVICE_PORT_HTTP, VAULT_SERVICE_PORT_HTTPS_INTERNAL, VAULT_STANDBY_PORT, VAULT_STANDBY_PORT_8200_TCP, VAULT_STANDBY_PORT_8200_TCP_ADDR, VAULT_STANDBY_PORT_8200_TCP_PORT, VAULT_STANDBY_PORT_8200_TCP_PROTO, VAULT_STANDBY_PORT_8201_TCP, VAULT_STANDBY_PORT_8201_TCP_ADDR, VAULT_STANDBY_PORT_8201_TCP_PORT, VAULT_STANDBY_PORT_8201_TCP_PROTO, VAULT_STANDBY_SERVICE_HOST, VAULT_STANDBY_SERVICE_PORT, VAULT_STANDBY_SERVICE_PORT_HTTP, VAULT_STANDBY_SERVICE_PORT_HTTPS_INTERNAL, VAULT_UI_PORT, VAULT_UI_PORT_8200_TCP, VAULT_UI_PORT_8200_TCP_ADDR, VAULT_UI_PORT_8200_TCP_PORT, VAULT_UI_PORT_8200_TCP_PROTO, VAULT_UI_SERVICE_HOST, VAULT_UI_SERVICE_PORT, VAULT_UI_SERVICE_PORT_HTTP, VERSION
              Go Version: go1.21.3
              Listener 1: tcp (addr: "[::]:8200", cluster address: "[::]:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: 
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: raft (HA available)
                 Version: Vault v1.15.2, built 2023-11-06T11:33:28Z
             Version Sha: cf1b5cafa047bc8e4a3f93444fcb4011593b92cb

==> Vault server started! Log data will stream in below:

2024-01-15T18:44:02.667Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2024-01-15T18:44:02.828Z [INFO]  incrementing seal generation: generation=1
2024-01-15T18:44:02.828Z [INFO]  core: Initializing version history cache for core
2024-01-15T18:44:02.828Z [INFO]  events: Starting event system
2024-01-15T18:44:07.387Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:07.387Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:12.383Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:12.383Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:17.392Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:17.392Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:22.382Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:22.382Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:27.385Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:27.385Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:32.392Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:32.392Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:37.386Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:37.386Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:42.388Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:42.388Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:47.387Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:47.387Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:52.388Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:52.388Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:44:57.380Z [INFO]  core: security barrier not initialized
2024-01-15T18:44:57.380Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:02.398Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:02.398Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:07.384Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:07.384Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:11.546Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:11.546Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:12.386Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:12.386Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:17.391Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:17.391Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:22.388Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:22.388Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:27.393Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:27.393Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:32.409Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:32.409Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:37.388Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:37.388Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:42.386Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:42.386Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:47.387Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:47.387Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:52.394Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:52.394Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:45:57.387Z [INFO]  core: security barrier not initialized
2024-01-15T18:45:57.387Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:02.385Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:02.385Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:07.397Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:07.397Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:12.383Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:12.383Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:17.376Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:17.376Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:22.398Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:22.398Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:23.553Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:23.553Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:27.394Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:27.394Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:32.386Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:32.386Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:37.389Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:37.389Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:42.388Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:42.388Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:47.391Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:47.391Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:52.381Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:52.381Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:46:57.386Z [INFO]  core: security barrier not initialized
2024-01-15T18:46:57.386Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:47:02.386Z [INFO]  core: security barrier not initialized
2024-01-15T18:47:02.386Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:47:07.394Z [INFO]  core: security barrier not initialized
2024-01-15T18:47:07.394Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:47:12.399Z [INFO]  core: security barrier not initialized
2024-01-15T18:47:12.400Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:47:17.398Z [INFO]  core: security barrier not initialized
2024-01-15T18:47:17.398Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:47:18.212Z [INFO]  core: security barrier not initialized
2024-01-15T18:47:18.212Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:47:18.213Z [INFO]  core: security barrier not initialized
2024-01-15T18:47:18.222Z [INFO]  storage.raft: creating Raft: config="&raft.Config{ProtocolVersion:3, HeartbeatTimeout:5000000000, ElectionTimeout:5000000000, CommitTimeout:50000000, MaxAppendEntries:64, BatchApplyCh:true, ShutdownOnRemove:true, TrailingLogs:0x2800, SnapshotInterval:120000000000, SnapshotThreshold:0x2000, LeaderLeaseTimeout:2500000000, LocalID:\"efdf9691-b3da-0ffa-43e6-f624570adb1c\", NotifyCh:(chan<- bool)(0xc002e28930), LogOutput:io.Writer(nil), LogLevel:\"DEBUG\", Logger:(*hclog.interceptLogger)(0xc002d836e0), NoSnapshotRestoreOnStart:true, skipStartup:false}"
2024-01-15T18:47:18.227Z [INFO]  storage.raft: initial configuration: index=1 servers="[{Suffrage:Voter ID:efdf9691-b3da-0ffa-43e6-f624570adb1c Address:vault-0.vault-internal:8201}]"
2024-01-15T18:47:18.227Z [INFO]  storage.raft: entering follower state: follower="Node at efdf9691-b3da-0ffa-43e6-f624570adb1c [Follower]" leader-address= leader-id=
2024-01-15T18:47:22.397Z [INFO]  core: security barrier not initialized
2024-01-15T18:47:26.970Z [WARN]  storage.raft: heartbeat timeout reached, starting election: last-leader-addr= last-leader-id=
2024-01-15T18:47:26.970Z [INFO]  storage.raft: entering candidate state: node="Node at efdf9691-b3da-0ffa-43e6-f624570adb1c [Candidate]" term=2
2024-01-15T18:47:26.994Z [INFO]  storage.raft: election won: term=2 tally=1
2024-01-15T18:47:26.994Z [INFO]  storage.raft: entering leader state: leader="Node at efdf9691-b3da-0ffa-43e6-f624570adb1c [Leader]"
2024-01-15T18:47:27.006Z [INFO]  core: seal configuration missing, not initialized
2024-01-15T18:47:27.026Z [INFO]  core: security barrier initialized: stored=1 shares=5 threshold=3
2024-01-15T18:47:27.078Z [INFO]  core: post-unseal setup starting
2024-01-15T18:47:27.087Z [INFO]  core: loaded wrapping token key
2024-01-15T18:47:27.087Z [INFO]  core: successfully setup plugin runtime catalog
2024-01-15T18:47:27.087Z [INFO]  core: successfully setup plugin catalog: plugin-directory=""
2024-01-15T18:47:27.087Z [INFO]  core: no mounts; adding default mount table
2024-01-15T18:47:27.116Z [INFO]  core: successfully mounted: type=cubbyhole version="v1.15.2+builtin.vault" path=cubbyhole/ namespace="ID: root. Path: "
2024-01-15T18:47:27.116Z [INFO]  core: successfully mounted: type=system version="v1.15.2+builtin.vault" path=sys/ namespace="ID: root. Path: "
2024-01-15T18:47:27.116Z [INFO]  core: successfully mounted: type=identity version="v1.15.2+builtin.vault" path=identity/ namespace="ID: root. Path: "
2024-01-15T18:47:27.176Z [INFO]  core: successfully mounted: type=token version="v1.15.2+builtin.vault" path=token/ namespace="ID: root. Path: "
2024-01-15T18:47:27.181Z [INFO]  rollback: Starting the rollback manager with 256 workers
2024-01-15T18:47:27.181Z [INFO]  rollback: starting rollback manager
2024-01-15T18:47:27.181Z [INFO]  core: restoring leases
2024-01-15T18:47:27.181Z [INFO]  expiration: lease restore complete
2024-01-15T18:47:27.192Z [INFO]  identity: entities restored
2024-01-15T18:47:27.192Z [INFO]  identity: groups restored
2024-01-15T18:47:27.192Z [INFO]  core: usage gauge collection is disabled
2024-01-15T18:47:27.210Z [INFO]  core: Recorded vault version: vault version=1.15.2 upgrade time="2024-01-15 18:47:27.192642348 +0000 UTC" build date=2023-11-06T11:33:28Z
2024-01-15T18:47:27.722Z [INFO]  core: post-unseal setup complete
2024-01-15T18:47:27.736Z [INFO]  core: root token generated
2024-01-15T18:47:27.745Z [INFO]  core: pre-seal teardown starting
2024-01-15T18:47:27.745Z [INFO]  core: stopping raft active node
2024-01-15T18:47:27.745Z [INFO]  rollback: stopping rollback manager
2024-01-15T18:47:27.745Z [INFO]  core: pre-seal teardown complete
[user@rocky9 lab-13]$ 
```

* Обратите внимание на параметры Initialized, Sealed

```bash
kubectl exec -it vault-0 -- vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       1
Threshold          1
Unseal Progress    0/1
Unseal Nonce       n/a
Version            1.2.2
HA Enabled         true
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    0/3
Unseal Nonce       n/a
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       raft
HA Enabled         true
command terminated with exit code 2
[user@rocky9 lab-13]$ 
```

---

## Распечатаем  vault

* Обратите внимание на переменные окружения в подах

```bash
 kubectl exec -it vault-0 env | grep VAULT
 VAULT_ADDR=http://127.0.0.1:8200
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 env | grep VAULT
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
VAULT_K8S_POD_NAME=vault-0
VAULT_K8S_NAMESPACE=default
VAULT_API_ADDR=http://10.112.128.15:8200
VAULT_ADDR=http://127.0.0.1:8200
VAULT_CLUSTER_ADDR=https://vault-0.vault-internal:8201
VAULT_ACTIVE_SERVICE_HOST=10.96.181.128
VAULT_PORT_8201_TCP_ADDR=10.96.241.34
VAULT_UI_SERVICE_HOST=10.96.227.61
VAULT_UI_SERVICE_PORT_HTTP=8200
VAULT_AGENT_INJECTOR_SVC_PORT=tcp://10.96.227.31:443
VAULT_STANDBY_PORT_8201_TCP=tcp://10.96.180.204:8201
VAULT_ACTIVE_PORT_8200_TCP_PROTO=tcp
VAULT_SERVICE_PORT=8200
VAULT_ACTIVE_SERVICE_PORT=8200
VAULT_ACTIVE_PORT_8201_TCP_PROTO=tcp
VAULT_STANDBY_PORT_8201_TCP_ADDR=10.96.180.204
VAULT_STANDBY_SERVICE_HOST=10.96.180.204
VAULT_STANDBY_PORT_8200_TCP_PROTO=tcp
VAULT_STANDBY_PORT_8200_TCP_PORT=8200
VAULT_STANDBY_PORT_8200_TCP_ADDR=10.96.180.204
VAULT_STANDBY_PORT_8201_TCP_PORT=8201
VAULT_SERVICE_PORT_HTTP=8200
VAULT_UI_PORT_8200_TCP_PORT=8200
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR=10.96.227.31
VAULT_STANDBY_PORT_8201_TCP_PROTO=tcp
VAULT_ACTIVE_PORT_8201_TCP_ADDR=10.96.181.128
VAULT_PORT=tcp://10.96.241.34:8200
VAULT_STANDBY_SERVICE_PORT=8200
VAULT_PORT_8201_TCP=tcp://10.96.241.34:8201
VAULT_PORT_8200_TCP_PORT=8200
VAULT_PORT_8201_TCP_PROTO=tcp
VAULT_UI_PORT_8200_TCP_ADDR=10.96.227.61
VAULT_ACTIVE_PORT_8200_TCP_ADDR=10.96.181.128
VAULT_STANDBY_PORT_8200_TCP=tcp://10.96.180.204:8200
VAULT_ACTIVE_PORT=tcp://10.96.181.128:8200
VAULT_ACTIVE_PORT_8201_TCP_PORT=8201
VAULT_STANDBY_PORT=tcp://10.96.180.204:8200
VAULT_ACTIVE_PORT_8200_TCP_PORT=8200
VAULT_PORT_8200_TCP_PROTO=tcp
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO=tcp
VAULT_PORT_8200_TCP_ADDR=10.96.241.34
VAULT_UI_PORT_8200_TCP=tcp://10.96.227.61:8200
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT=443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP=tcp://10.96.227.31:443
VAULT_STANDBY_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_SERVICE_HOST=10.96.241.34
VAULT_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_PORT_8201_TCP_PORT=8201
VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST=10.96.227.31
VAULT_ACTIVE_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_ACTIVE_PORT_8200_TCP=tcp://10.96.181.128:8200
VAULT_UI_SERVICE_PORT=8200
VAULT_UI_PORT=tcp://10.96.227.61:8200
VAULT_PORT_8200_TCP=tcp://10.96.241.34:8200
VAULT_UI_PORT_8200_TCP_PROTO=tcp
VAULT_ACTIVE_PORT_8201_TCP=tcp://10.96.181.128:8201
VAULT_STANDBY_SERVICE_PORT_HTTP=8200
VAULT_ACTIVE_SERVICE_PORT_HTTP=8200
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS=443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT=443
[user@rocky9 lab-13]$ 
```

*  Распечатать нужно каждый под 



```bash
kubectl exec -it vault-0 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-1 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-2 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
```

``
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'N8ZVIXld25WviRoLUZp+IeutwBFV3sgD8H+LRhxnJVbe'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       18013c6c-e2ed-4879-00c9-25f9f33604f4
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       raft
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'Hw83M4i+wCkbUsXrizvKM5NP9bHUb9Px04vuHVadYmUZ'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       18013c6c-e2ed-4879-00c9-25f9f33604f4
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       raft
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator unseal '3vF+dmsIQqLJzKkwPgiXgKp0x9RF51dJt1xNNHbIWpkV'
Key                     Value
---                     -----
Seal Type               shamir
Initialized             true
Sealed                  false
Total Shares            5
Threshold               3
Version                 1.15.2
Build Date              2023-11-06T11:33:28Z
Storage Type            raft
Cluster Name            vault-cluster-98abcb76
Cluster ID              8547dad7-5b8c-e4bb-af3a-0d334f463c91
HA Enabled              true
HA Cluster              https://vault-0.vault-internal:8201
HA Mode                 active
Active Since            2024-01-15T18:58:10.577764069Z
Raft Committed Index    54
Raft Applied Index      54
[user@rocky9 lab-13]$ 
```


* добавьте выдачу ```vault status```  в README.md 
 
---
 
 ##  Посмотрим список доступных авторизаций
 
* выполните
```kubectl exec -it vault-0 --  vault auth list```

* получите ошибку

```bash
Error listing enabled authentications: Error making API request.

URL: GET http://127.0.0.1:8200/v1/sys/auth
Code: 400. Errors:

* missing client token
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 --  vault auth list
Error listing enabled authentications: Error making API request.

URL: GET http://127.0.0.1:8200/v1/sys/auth
Code: 403. Errors:

* permission denied
command terminated with exit code 2
[user@rocky9 lab-13]$ 
```

---
##  Залогинимся в vault (у нас есть root token)
  
```bash
kubectl exec -it vault-0 --  vault login

Token (will be hidden):
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.oen1aEGBLNV3VdnBqQwRwXQY
token_accessor       MqfiYz1jChDqSB4sbvaRQcW7
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
[user@rocky9 lab-13]$ 
```

* Вывод после логина добавьте в README.md
* повторно запросим список авторизаций

```bash
kubectl exec -it vault-0 --  vault auth list
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault auth list
Path      Type     Accessor               Description                Version
----      ----     --------               -----------                -------
token/    token    auth_token_615db6d7    token based credentials    n/a
[user@rocky9 lab-13]$ 
```

* Вывод сохранить в README.md

---

## Заведем секреты

```bash
kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
kubectl exec -it vault-0 -- vault secrets list --detailed
kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs'
kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs'
kubectl exec -it vault-0 -- vault read otus/otus-ro/config
kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
Success! Enabled the kv secrets engine at: otus/
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault secrets list --detailed
Path          Plugin       Accessor              Default TTL    Max TTL    Force No Cache    Replication    Seal Wrap    External Entropy Access    Options    Description                                                UUID                                    Version    Running Version          Running SHA256    Deprecation Status
----          ------       --------              -----------    -------    --------------    -----------    ---------    -----------------------    -------    -----------                                                ----                                    -------    ---------------          --------------    ------------------
cubbyhole/    cubbyhole    cubbyhole_28ec713a    n/a            n/a        false             local          false        false                      map[]      per-token private secret storage                           e8a3d249-05d3-0f67-1969-023bef40786c    n/a        v1.15.2+builtin.vault    n/a               n/a
identity/     identity     identity_96658b25     system         system     false             replicated     false        false                      map[]      identity store                                             da4af9bb-f7f5-4379-8f65-db0b78439ecd    n/a        v1.15.2+builtin.vault    n/a               n/a
otus/         kv           kv_888e46fe           system         system     false             replicated     false        false                      map[]      n/a                                                        87974537-6381-f4e1-383e-6760bf13f071    n/a        v0.16.1+builtin          n/a               supported
sys/          system       system_4fe5d97f       n/a            n/a        false             replicated     true         false                      map[]      system endpoints used for control, policy and debugging    d3d98ff2-04a6-f2c3-5e5e-831baea487f3    n/a        v1.15.2+builtin.vault    n/a               n/a
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs'
Success! Data written to: otus/otus-ro/config
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs'
Success! Data written to: otus/otus-rw/config
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
====== Data ======
Key         Value
---         -----
password    asajkjkahs
username    otus
[user@rocky9 lab-13]$ 
```


* выыод команды чтения секрета добавить в README.md

---

##  Включим авторизацию черерз k8s
```bash
kubectl exec -it vault-0 -- vault auth enable kubernetes
kubectl exec -it vault-0 -- vault auth list
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault auth enable kubernetes
Success! Enabled kubernetes auth method at: kubernetes/
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault auth list
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_8839f845    n/a                        n/a
token/         token         auth_token_615db6d7         token based credentials    n/a
[user@rocky9 lab-13]$ 
```

* Обновленный список авторизаций - добавить в  README.md

---
##  Создадим yaml для ClusterRoleBinding

- vault-auth-service-account.yml

```yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: default
EOF
* файл должен быть приложен в ДЗ
```

```
[user@rocky9 lab-13]$ vi vault-auth-service-account.yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: default
```

---
##  Создадим Service Account vault-auth и применим ClusterRoleBinding

```bash
# Create a service account, 'vault-auth'
$ kubectl create serviceaccount vault-auth

# Update the 'vault-auth' service account
$ kubectl apply --filename vault-auth-service-account.yml
```

```
[user@rocky9 lab-13]$ kubectl create serviceaccount vault-auth
serviceaccount/vault-auth created
[user@rocky9 lab-13]$ 
```

```
[user@rocky9 lab-13]$ kubectl apply -f ./vault-auth-service-account.yml 
clusterrolebinding.rbac.authorization.k8s.io/role-tokenreview-binding created
[user@rocky9 lab-13]$ 
```

---

## Подготовим переменные для записи в конфиг кубер авторизации


```bash
export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')

### alternative way
export K8S_HOST=$(kubectl cluster-info | grep ‘Kubernetes master’ | awk ‘/https/ {print $NF}’ | sed ’s/\x1b\[[0-9;]*m//g’ )
```

```
[user@rocky9 lab-13]$ export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
[user@rocky9 lab-13]$ export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
[user@rocky9 lab-13]$ export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
[user@rocky9 lab-13]$ export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')
[user@rocky9 lab-13]$ 
```

```
[user@rocky9 lab-13]$ export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g' )
[user@rocky9 lab-13]$ 
```

* Обратите внимание на конструкцию ```sed ’s/\x1b\[[0-9;]*m//g```, что по вашему она делает?

---

## Запишем конфиг в vault

```
kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
token_reviewer_jwt="$SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$SA_CA_CRT"
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
token_reviewer_jwt="$SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$SA_CA_CRT"
Success! Data written to: auth/kubernetes/config
[user@rocky9 lab-13]$ 
```

---

## Создадим файл политики

```bash
tee otus-policy.hcl <<EOF
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}

path "otus/otus-rw/*" {
capabilities = ["read", "create", "list"]
}
EOF
```

```
[user@rocky9 lab-13]$ tee otus-policy.hcl <<EOF
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}

path "otus/otus-rw/*" {
capabilities = ["read", "create", "list"]
}
EOF
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}

path "otus/otus-rw/*" {
capabilities = ["read", "create", "list"]
}
[user@rocky9 lab-13]$ 
```

---

## создадим политку и роль в vault 

```
kubectl cp otus-policy.hcl vault-0:./

kubectl exec -it vault-0 -- vault policy write otus-policy /otus-policy.hcl

kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
```

```
[user@rocky9 lab-13]$ kubectl cp ./otus-policy.hcl vault-0:./
tar: can't open 'otus-policy.hcl': Permission denied
command terminated with exit code 1
[user@rocky9 lab-13]$
```
Попробовать отключить firewall в kuberneyes !!!

---

## Проверим как работает авторизация

* Создадим под с привязанным сервис аккоунтом и установим туда curl и jq

```bash
kubectl run --generator=run-pod/v1 tmp --rm -i --tty --serviceaccount=vault-auth --image alpine:3.7
apk add curl jq
```

* Залогинимся и получим клиентский токен

```bash
VAULT_ADDR=http://vault:8200
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
TOKEN=$(curl -k -s --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{p
rint $2}')
```

---

## Прочитаем записанные ранее секреты и попробуем их обновить

* используйте свой клиентский токен
* проверим чтение
```bash
curl --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-ro/config
curl --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-rw/config
```
* проверим запись
```bash
curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-ro/config
curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-rw/config
curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-rw/config1
```

---

## Разберемся с ошибками при записи
* Почему мы смогли записать otus-rw/config1 но не смогли otus-rw/config
* Измените политику так, чтобы можно было менять otus-rw/config
* Ответы на вопросы добавить в README.md

---

##  Use case использования авторизации через кубер

* Авторизуемся через vault-agent и получим клиентский токен
* Через consul-template достанем секрет и положим его в nginx
* Итог - nginx получил секрет из волта, не зная ничего про волт


---

##  Заберем репозиторий с примерами

```bash 
git clone https://github.com/hashicorp/vault-guides.git
cd vault-guides/identity/vault-agent-k8s-demo
```
* В каталоге configs-k8s скорректируйте конфиги с учетом ранее созданых ролей и секретов
* Проверьте и скорректируйте конфиг example-k8s-spec.yml
* Скорректированные конфиги приложить к ДЗ

---

##  Запускаем пример

```bash
    # Create a ConfigMap, example-vault-agent-config
    $ kubectl create configmap example-vault-agent-config --from-file=./configs-k8s/

    # View the created ConfigMap
    $ kubectl get configmap example-vault-agent-config -o yaml

    # Finally, create vault-agent-example Pod
    $ kubectl apply -f example-k8s-spec.yml --record
```

---

## Проверка

* законнектится к поду nginx и вытащить оттуда index.html
* index.html приложить к ДЗ


---
## создадим  CA на базе vault 

* Включим pki секретс

```bash
 kubectl exec -it vault-0 -- vault secrets enable pki
 kubectl exec -it vault-0 -- vault secrets tune -max-lease-ttl=87600h pki
 kubectl exec -it vault-0 -- vault write -field=certificate pki/root/generate/internal  \
 common_name="exmaple.ru"  ttl=87600h > CA_cert.crt
```

---
## пропишем урлы для ca и отозванных сертификатов
 
```bash
 kubectl exec -it vault-0 -- vault write pki/config/urls  \
 issuing_certificates="http://vault:8200/v1/pki/ca"       \
 crl_distribution_points="http://vault:8200/v1/pki/crl"
```
---
## создадим промежуточный сертификат
 
```bash
kubectl exec -it vault-0 -- vault secrets enable --path=pki_int pki
kubectl exec -it vault-0 -- vault secrets tune -max-lease-ttl=87600h pki_int
kubectl exec -it vault-0 -- vault write -format=json pki_int/intermediate/generate/internal  \
common_name="example.ru Intermediate Authority"         | jq -r '.data.csr' > pki_intermediate.csr
```

---
## пропишем промежуточный сертификат в vault

```bash
kubectl cp pki_intermediate.csr vault-0:./
kubectl exec -it vault-0 -- vault write -format=json pki/root/sign-intermediate \
csr=@pki_intermediate.csr   \      
format=pem_bundle ttl="43800h" |  jq -r '.data.certificate' > intermediate.cert.pem
kubectl cp intermediate.cert.pem vault-0:./
kubectl exec -it vault-0 -- vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
```
   
---
## Создадим и отзовем новые сертификаты
* Создадим роль для выдачи с    ертификатов
```bash
kubectl exec -it vault-0 -- vault write pki_int/roles/example-dot-ru \  
allowed_domains="example.ru" allow_subdomains=true   max_ttl="720h"
```
*  Создадим и отзовем сертификат
```bash
kubectl exec -it vault-0 -- vault write pki_int/issue/devlab-dot-ru common_name="gitlab.devlab.ru" ttl="24h"
kubectl exec -it vault-0 -- vault write pki_int/revoke serial_number="71:a8:4f:4c:bd:74:c6:d8:ea:27:64:cb:53:ef:80:1a:6b:c8:be:e3"
```
* выдачу при создании сертификата добавить в README.md

---
## включить TLS (было продемонстрировано в лекции)
* реализовать доступ к vault через  https с CA из кубернетес
* в README.md описать последовательность действий
* предоставить примеры работы курлом

---
## Настроить автообновление сертификатов 
* запустить nginx
* реализовать автообнвление сертификатов для nginx c помощью consul-template или vault-inject
* в ридми приложить скриншоты сртификатов из броузера (2 штуки, для демоснтрации рефреша)
* конфиги для развертывания приложеть в репозиторий

---
## 🐍 Задание со 🌟 
* Настроить autounseal 
* провайдер для autoanseal на ваш выбор, как вариант второй волт
* описать все в README.md




