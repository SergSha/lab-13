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
  ...
  ha:
    enabled: true
    raft:
      enabled: true
  ...
    config: |
      ui = true

      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "consul" {
        path = "vault"
        #address = "HOST_IP:8500"             # <--- закоментировал
        address = "consul-consul-server:8500" # <--- добавил правильную строку
      }
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
[user@redos lab-13]$ helm status vault
NAME: vault
LAST DEPLOYED: Tue Jan 16 11:08:05 2024
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
[user@redos lab-13]$
```

```
[user@redos lab-13]$ kubectl logs vault-0
==> Vault server configuration:

Administrative Namespace: 
             Api Address: http://10.112.128.8:8200
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

2024-01-16T08:08:49.602Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2024-01-16T08:08:49.657Z [INFO]  incrementing seal generation: generation=1
2024-01-16T08:08:49.657Z [INFO]  core: Initializing version history cache for core
2024-01-16T08:08:49.657Z [INFO]  events: Starting event system
2024-01-16T08:08:55.121Z [INFO]  core: security barrier not initialized
2024-01-16T08:08:55.121Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:00.126Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:00.126Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:05.113Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:05.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:10.122Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:10.122Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:15.104Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:15.104Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:20.113Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:20.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:25.110Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:25.110Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:30.106Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:30.106Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:35.104Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:35.104Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:40.109Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:40.109Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:45.114Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:45.114Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:50.101Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:50.101Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:55.108Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:55.108Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:00.121Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:00.121Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:05.118Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:05.118Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:05.814Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:05.814Z [INFO]  core: seal configuration missing, not initialized
[user@redos lab-13]$ 
```



---

## Инициализируем vault

* проведите инициализацию через любой под vault'а
```kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault operator init --key-shares=5 --key-threshold=3
Unseal Key 1: IsJE273ftipA49lcDcBmZo+uuumLAFNUZiqCgRFWSb3E
Unseal Key 2: ECLvB66PF7LQWJ7foGH7dnDBN/wIlcrurLiLk8kNjgP8
Unseal Key 3: WROlsNYieHJPbXDPw8PBACK4a/j9O6mA704xMJtsAygU
Unseal Key 4: JtqT6q81MZbBAC5ALhgwCd3Nv4musQgBnjUt3oNvP8hk
Unseal Key 5: o0ugLPAH9RWKiUUTQW1JUwN3jrBh8dI2w3O0r8B7Fc4P

Initial Root Token: hvs.c3RJZrHaAYeWzIHdl0r07aoJ

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 3 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
[user@redos lab-13]$
```

* сохраните ключи, полученные при инициализации
```
Unseal Key 1: IsJE273ftipA49lcDcBmZo+uuumLAFNUZiqCgRFWSb3E
Unseal Key 2: ECLvB66PF7LQWJ7foGH7dnDBN/wIlcrurLiLk8kNjgP8
Unseal Key 3: WROlsNYieHJPbXDPw8PBACK4a/j9O6mA704xMJtsAygU
Unseal Key 4: JtqT6q81MZbBAC5ALhgwCd3Nv4musQgBnjUt3oNvP8hk
Unseal Key 5: o0ugLPAH9RWKiUUTQW1JUwN3jrBh8dI2w3O0r8B7Fc4P

Initial Root Token: hvs.c3RJZrHaAYeWzIHdl0r07aoJ
```
* вывод добавьте в README.md

* 🐍 поэкспериментируйте с разными значениями --key-shares --key-threshold

---

## Проверим состояние vault'а


```kubectl logs vault-0```

```
[user@redos lab-13]$ kubectl logs vault-0
==> Vault server configuration:

Administrative Namespace: 
             Api Address: http://10.112.128.8:8200
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

2024-01-16T08:08:49.602Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2024-01-16T08:08:49.657Z [INFO]  incrementing seal generation: generation=1
2024-01-16T08:08:49.657Z [INFO]  core: Initializing version history cache for core
2024-01-16T08:08:49.657Z [INFO]  events: Starting event system
2024-01-16T08:08:55.121Z [INFO]  core: security barrier not initialized
2024-01-16T08:08:55.121Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:00.126Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:00.126Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:05.113Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:05.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:10.122Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:10.122Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:15.104Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:15.104Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:20.113Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:20.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:25.110Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:25.110Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:30.106Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:30.106Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:35.104Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:35.104Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:40.109Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:40.109Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:45.114Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:45.114Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:50.101Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:50.101Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:09:55.108Z [INFO]  core: security barrier not initialized
2024-01-16T08:09:55.108Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:00.121Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:00.121Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:05.118Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:05.118Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:05.814Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:05.814Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:10.110Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:10.110Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:15.114Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:15.114Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:20.125Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:20.125Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:25.113Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:25.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:30.125Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:30.125Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:35.113Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:35.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:40.112Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:40.112Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:45.126Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:45.127Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:50.109Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:50.109Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:10:55.112Z [INFO]  core: security barrier not initialized
2024-01-16T08:10:55.112Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:00.117Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:00.117Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:05.118Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:05.118Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:10.108Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:10.108Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:10.831Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:10.831Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:15.110Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:15.110Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:20.103Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:20.103Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:25.105Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:25.105Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:30.104Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:30.104Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:33.550Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:33.550Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:33.551Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:33.566Z [INFO]  storage.raft: creating Raft: config="&raft.Config{ProtocolVersion:3, HeartbeatTimeout:5000000000, ElectionTimeout:5000000000, CommitTimeout:50000000, MaxAppendEntries:64, BatchApplyCh:true, ShutdownOnRemove:true, TrailingLogs:0x2800, SnapshotInterval:120000000000, SnapshotThreshold:0x2000, LeaderLeaseTimeout:2500000000, LocalID:\"870204de-2ae4-6a6c-30a9-b7b5dd4dd90d\", NotifyCh:(chan<- bool)(0xc002ada540), LogOutput:io.Writer(nil), LogLevel:\"DEBUG\", Logger:(*hclog.interceptLogger)(0xc002f016e0), NoSnapshotRestoreOnStart:true, skipStartup:false}"
2024-01-16T08:11:33.586Z [INFO]  storage.raft: initial configuration: index=1 servers="[{Suffrage:Voter ID:870204de-2ae4-6a6c-30a9-b7b5dd4dd90d Address:vault-0.vault-internal:8201}]"
2024-01-16T08:11:33.586Z [INFO]  storage.raft: entering follower state: follower="Node at 870204de-2ae4-6a6c-30a9-b7b5dd4dd90d [Follower]" leader-address= leader-id=
2024-01-16T08:11:35.108Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:40.106Z [INFO]  core: security barrier not initialized
2024-01-16T08:11:40.319Z [WARN]  storage.raft: heartbeat timeout reached, starting election: last-leader-addr= last-leader-id=
2024-01-16T08:11:40.319Z [INFO]  storage.raft: entering candidate state: node="Node at 870204de-2ae4-6a6c-30a9-b7b5dd4dd90d [Candidate]" term=2
2024-01-16T08:11:40.324Z [INFO]  storage.raft: election won: term=2 tally=1
2024-01-16T08:11:40.324Z [INFO]  storage.raft: entering leader state: leader="Node at 870204de-2ae4-6a6c-30a9-b7b5dd4dd90d [Leader]"
2024-01-16T08:11:40.332Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:40.332Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T08:11:40.348Z [INFO]  core: security barrier initialized: stored=1 shares=5 threshold=3
2024-01-16T08:11:40.392Z [INFO]  core: post-unseal setup starting
2024-01-16T08:11:40.402Z [INFO]  core: loaded wrapping token key
2024-01-16T08:11:40.403Z [INFO]  core: successfully setup plugin runtime catalog
2024-01-16T08:11:40.403Z [INFO]  core: successfully setup plugin catalog: plugin-directory=""
2024-01-16T08:11:40.404Z [INFO]  core: no mounts; adding default mount table
2024-01-16T08:11:40.420Z [INFO]  core: successfully mounted: type=cubbyhole version="v1.15.2+builtin.vault" path=cubbyhole/ namespace="ID: root. Path: "
2024-01-16T08:11:40.426Z [INFO]  core: successfully mounted: type=system version="v1.15.2+builtin.vault" path=sys/ namespace="ID: root. Path: "
2024-01-16T08:11:40.433Z [INFO]  core: successfully mounted: type=identity version="v1.15.2+builtin.vault" path=identity/ namespace="ID: root. Path: "
2024-01-16T08:11:40.532Z [INFO]  core: successfully mounted: type=token version="v1.15.2+builtin.vault" path=token/ namespace="ID: root. Path: "
2024-01-16T08:11:40.536Z [INFO]  rollback: Starting the rollback manager with 256 workers
2024-01-16T08:11:40.536Z [INFO]  rollback: starting rollback manager
2024-01-16T08:11:40.536Z [INFO]  core: restoring leases
2024-01-16T08:11:40.536Z [INFO]  expiration: lease restore complete
2024-01-16T08:11:40.563Z [INFO]  identity: entities restored
2024-01-16T08:11:40.563Z [INFO]  identity: groups restored
2024-01-16T08:11:40.565Z [INFO]  core: usage gauge collection is disabled
2024-01-16T08:11:40.573Z [INFO]  core: Recorded vault version: vault version=1.15.2 upgrade time="2024-01-16 08:11:40.565153947 +0000 UTC" build date=2023-11-06T11:33:28Z
2024-01-16T08:11:41.042Z [INFO]  core: post-unseal setup complete
2024-01-16T08:11:41.070Z [INFO]  core: root token generated
2024-01-16T08:11:41.080Z [INFO]  core: pre-seal teardown starting
2024-01-16T08:11:41.080Z [INFO]  core: stopping raft active node
2024-01-16T08:11:41.080Z [INFO]  rollback: stopping rollback manager
2024-01-16T08:11:41.080Z [INFO]  core: pre-seal teardown complete
[user@redos lab-13]$ 
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
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault status
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
[user@redos lab-13]$ 
```

---

## Распечатаем  vault

* Обратите внимание на переменные окружения в подах

```bash
 kubectl exec -it vault-0 -- env | grep VAULT
 VAULT_ADDR=http://127.0.0.1:8200
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- env | grep VAULT
VAULT_CLUSTER_ADDR=https://vault-0.vault-internal:8201
VAULT_K8S_NAMESPACE=default
VAULT_ADDR=http://127.0.0.1:8200
VAULT_K8S_POD_NAME=vault-0
VAULT_API_ADDR=http://10.112.128.8:8200
VAULT_PORT_8201_TCP_PORT=8201
VAULT_ACTIVE_PORT_8201_TCP_PORT=8201
VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST=10.96.176.124
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT=443
VAULT_SERVICE_HOST=10.96.136.135
VAULT_SERVICE_PORT=8200
VAULT_ACTIVE_PORT_8200_TCP_ADDR=10.96.157.138
VAULT_ACTIVE_PORT_8201_TCP_PROTO=tcp
VAULT_UI_SERVICE_PORT=8200
VAULT_ACTIVE_PORT_8200_TCP_PORT=8200
VAULT_PORT=tcp://10.96.136.135:8200
VAULT_UI_PORT_8200_TCP=tcp://10.96.169.203:8200
VAULT_UI_PORT_8200_TCP_PROTO=tcp
VAULT_STANDBY_PORT_8201_TCP_PORT=8201
VAULT_ACTIVE_SERVICE_PORT_HTTP=8200
VAULT_STANDBY_SERVICE_PORT_HTTP=8200
VAULT_STANDBY_PORT_8201_TCP_ADDR=10.96.148.158
VAULT_ACTIVE_PORT_8200_TCP_PROTO=tcp
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS=443
VAULT_STANDBY_PORT_8201_TCP=tcp://10.96.148.158:8201
VAULT_ACTIVE_PORT=tcp://10.96.157.138:8200
VAULT_AGENT_INJECTOR_SVC_PORT=tcp://10.96.176.124:443
VAULT_PORT_8200_TCP_ADDR=10.96.136.135
VAULT_UI_PORT_8200_TCP_ADDR=10.96.169.203
VAULT_STANDBY_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_ACTIVE_SERVICE_HOST=10.96.157.138
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP=tcp://10.96.176.124:443
VAULT_PORT_8200_TCP=tcp://10.96.136.135:8200
VAULT_PORT_8200_TCP_PORT=8200
VAULT_PORT_8201_TCP_PROTO=tcp
VAULT_ACTIVE_PORT_8201_TCP_ADDR=10.96.157.138
VAULT_PORT_8201_TCP=tcp://10.96.136.135:8201
VAULT_UI_SERVICE_PORT_HTTP=8200
VAULT_STANDBY_PORT_8201_TCP_PROTO=tcp
VAULT_STANDBY_PORT=tcp://10.96.148.158:8200
VAULT_STANDBY_PORT_8200_TCP=tcp://10.96.148.158:8200
VAULT_STANDBY_PORT_8200_TCP_PROTO=tcp
VAULT_ACTIVE_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO=tcp
VAULT_UI_PORT_8200_TCP_PORT=8200
VAULT_ACTIVE_PORT_8200_TCP=tcp://10.96.157.138:8200
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT=443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR=10.96.176.124
VAULT_SERVICE_PORT_HTTP=8200
VAULT_PORT_8200_TCP_PROTO=tcp
VAULT_STANDBY_PORT_8200_TCP_ADDR=10.96.148.158
VAULT_UI_PORT=tcp://10.96.169.203:8200
VAULT_STANDBY_SERVICE_PORT=8200
VAULT_STANDBY_PORT_8200_TCP_PORT=8200
VAULT_ACTIVE_SERVICE_PORT=8200
VAULT_ACTIVE_PORT_8201_TCP=tcp://10.96.157.138:8201
VAULT_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_UI_SERVICE_HOST=10.96.169.203
VAULT_PORT_8201_TCP_ADDR=10.96.136.135
VAULT_STANDBY_SERVICE_HOST=10.96.148.158
[user@redos lab-13]$ 
```

*  Распечатать нужно каждый под 



```bash
kubectl exec -it vault-0 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-1 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-2 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
```

``
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'IsJE273ftipA49lcDcBmZo+uuumLAFNUZiqCgRFWSb3E'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       051fd446-cbf2-8bc3-afd7-43913a46dff2
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       raft
HA Enabled         true
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'ECLvB66PF7LQWJ7foGH7dnDBN/wIlcrurLiLk8kNjgP8'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       051fd446-cbf2-8bc3-afd7-43913a46dff2
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       raft
HA Enabled         true
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'WROlsNYieHJPbXDPw8PBACK4a/j9O6mA704xMJtsAygU'
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
Cluster Name            vault-cluster-053a1493
Cluster ID              f003a037-1e9e-7a47-5ba3-99bb55de8057
HA Enabled              true
HA Cluster              https://vault-0.vault-internal:8201
HA Mode                 active
Active Since            2024-01-16T08:18:45.536266402Z
Raft Committed Index    52
Raft Applied Index      52
[user@redos lab-13]$ 
```


* добавьте выдачу ```vault status```  в README.md 

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault status
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
Cluster Name            vault-cluster-053a1493
Cluster ID              f003a037-1e9e-7a47-5ba3-99bb55de8057
HA Enabled              true
HA Cluster              https://vault-0.vault-internal:8201
HA Mode                 active
Active Since            2024-01-16T08:18:45.536266402Z
Raft Committed Index    56
Raft Applied Index      56
[user@redos lab-13]$ 
```
 
---
 
 ##  Посмотрим список доступных авторизаций
 
* выполните
```kubectl exec -it vault-0 -- vault auth list```

* получите ошибку

```bash
Error listing enabled authentications: Error making API request.

URL: GET http://127.0.0.1:8200/v1/sys/auth
Code: 400. Errors:

* missing client token
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault auth list
Error listing enabled authentications: Error making API request.

URL: GET http://127.0.0.1:8200/v1/sys/auth
Code: 403. Errors:

* permission denied
command terminated with exit code 2
[user@redos lab-13]$ 
```

---
##  Залогинимся в vault (у нас есть root token)
  
```bash
kubectl exec -it vault-0 --  vault login

Token (will be hidden):
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.c3RJZrHaAYeWzIHdl0r07aoJ
token_accessor       PdlCOFBqrggDgzkFg7po3YoR
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
[user@redos lab-13]$ 
```

* Вывод после логина добавьте в README.md
* повторно запросим список авторизаций

```bash
kubectl exec -it vault-0 -- vault auth list
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault auth list
Path      Type     Accessor               Description                Version
----      ----     --------               -----------                -------
token/    token    auth_token_b9ac5edb    token based credentials    n/a
[user@redos lab-13]$ 
```

* Вывод сохранить в README.md

---

## Заведем секреты

```bash
kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
kubectl exec -it vault-0 -- vault secrets list --detailed
kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='h7sgm4j9ztp'
kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='h7sgm4j9ztp'
kubectl exec -it vault-0 -- vault read otus/otus-ro/config
kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
Success! Enabled the kv secrets engine at: otus/
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault secrets list --detailed
Path          Plugin       Accessor              Default TTL    Max TTL    Force No Cache    Replication    Seal Wrap    External Entropy Access    Options    Description                                                UUID                                    Version    Running Version          Running SHA256    Deprecation Status
----          ------       --------              -----------    -------    --------------    -----------    ---------    -----------------------    -------    -----------                                                ----                                    -------    ---------------          --------------    ------------------
cubbyhole/    cubbyhole    cubbyhole_fae8fc5b    n/a            n/a        false             local          false        false                      map[]      per-token private secret storage                           91dc5554-93e1-8525-6c06-f955e2e017bc    n/a        v1.15.2+builtin.vault    n/a               n/a
identity/     identity     identity_c103bf20     system         system     false             replicated     false        false                      map[]      identity store                                             33305d63-0128-e543-0d8b-1e3b282501d5    n/a        v1.15.2+builtin.vault    n/a               n/a
otus/         kv           kv_4a926955           system         system     false             replicated     false        false                      map[]      n/a                                                        029ef552-112e-9c6a-f2a0-808a18ad1e8b    n/a        v0.16.1+builtin          n/a               supported
sys/          system       system_0b8536af       n/a            n/a        false             replicated     true         false                      map[]      system endpoints used for control, policy and debugging    f484970f-6b37-055c-acba-0a0a9611e824    n/a        v1.15.2+builtin.vault    n/a               n/a
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='h7sgm4j9ztp'
Success! Data written to: otus/otus-ro/config
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='h7sgm4j9ztp'
Success! Data written to: otus/otus-rw/config
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
Key                 Value
---                 -----
refresh_interval    768h
password            h7sgm4j9ztp
username            otus
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
====== Data ======
Key         Value
---         -----
password    h7sgm4j9ztp
username    otus
[user@redos lab-13]$ 
```


* выыод команды чтения секрета добавить в README.md

---

##  Включим авторизацию черерз k8s
```bash
kubectl exec -it vault-0 -- vault auth enable kubernetes
kubectl exec -it vault-0 -- vault auth list
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault auth enable kubernetes
Success! Enabled kubernetes auth method at: kubernetes/
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault auth list
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_46cd2bd4    n/a                        n/a
token/         token         auth_token_b9ac5edb         token based credentials    n/a
[user@redos lab-13]$ 
```

* Обновленный список авторизаций - добавить в  README.md

---
##  Создадим yaml для ClusterRoleBinding

- vault-auth-service-account.yml

```yaml
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
[user@redos lab-13]$ kubectl create serviceaccount vault-auth
serviceaccount/vault-auth created
[user@redos lab-13]$ 
```

```
[user@redos lab-13]$ kubectl apply -f ./vault-auth-service-account.yml 
clusterrolebinding.rbac.authorization.k8s.io/role-tokenreview-binding created
[user@redos lab-13]$ 
```

---

## Подготовим переменные для записи в конфиг кубер авторизации


```bash
export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')

### alternative way
export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g' )
```

```
[user@redos lab-13]$ export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
[user@redos lab-13]$ export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
[user@redos lab-13]$ export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
[user@redos lab-13]$ export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')
[user@redos lab-13]$ 
```

```
[user@redos lab-13]$ export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g' )
[user@redos lab-13]$ 
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
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
token_reviewer_jwt="$SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$SA_CA_CRT"
Success! Data written to: auth/kubernetes/config
[user@redos lab-13]$ 
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

## создадим политику и роль в vault 

```
kubectl cp otus-policy.hcl vault-0:/tmp/

kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl

kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
```

```
[user@redos lab-13]$ kubectl cp otus-policy.hcl vault-0:./tmp/
[user@redos lab-13]$ 
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
Success! Uploaded policy: otus-policy
[user@redos lab-13]$ 
```

```
[user@redos lab-13]$ kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
Success! Data written to: auth/kubernetes/role/otus
[user@redos lab-13]$ 
```

---

## Проверим как работает авторизация

* Создадим под с привязанным сервис аккоунтом и установим туда curl и jq

```bash
kubectl run --generator=run-pod/v1 tmp --rm -i --tty --serviceaccount=vault-auth --image alpine:3.7
apk add curl jq
```

```
[user@redos lab-13]$ kubectl run tmp --rm -i --tty --image alpine:3.7 --overrides='{ "spec": { "serviceAccount": "vault-auth" }  }'
If you don't see a command prompt, try pressing enter.
/ # apk add curl jq
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz
(1/6) Installing ca-certificates (20190108-r0)
(2/6) Installing libssh2 (1.9.0-r1)
(3/6) Installing libcurl (7.61.1-r3)
(4/6) Installing curl (7.61.1-r3)
(5/6) Installing oniguruma (6.6.1-r0)
(6/6) Installing jq (1.5-r5)
Executing busybox-1.27.2-r11.trigger
Executing ca-certificates-20190108-r0.trigger
OK: 7 MiB in 19 packages
/ # 
```

* Залогинимся и получим клиентский токен

```bash
VAULT_ADDR=http://vault:8200
KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
TOKEN=$(curl -k -s --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}')
```

```
/ # VAULT_ADDR=http://vault:8200
/ # KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
/ # curl --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAUL
T_ADDR/v1/auth/kubernetes/login | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
{ 0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  "request_id": "144c93f1-1e0b-2da8-e0dc-3471f247d3e0",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": null,
  "auth": {
    "client_token": "hvs.CAESIAv9d1Y3k_hkP1atOsZuJg2seadzcBZQVGt4FiQ7OAPVGh4KHGh2cy4wUkZQWjNoNHhKdEswT2ZRdlhMV0RmSnY",
    "accessor": "g0vEDE0btlespgsoQFkEvahp",
    "policies": [
      "default",
      "otus-policy"
    ],
    "token_policies": [
      "default",
      "otus-policy"
    ],
    "metadata": {
      "role": "otus",
      "service_account_name": "vault-auth",
      "service_account_namespace": "default",
      "service_account_secret_name": "",
      "service_account_uid": "9f1c64e5-58fc-4319-a1ca-47f5702399e2"
    },
    "lease_duration": 86400,
    "renewable": true,
    "entity_id": "f1d17a7f-ec53-3241-2fc8-7c8998e59fd7",
    "token_type": "service",
    "orphan": true,
    "mfa_requirement": null,
    "num_uses": 0
  }
}
100  1714  100   749  100   965   6294   8109 --:--:-- --:--:-- --:--:-- 14525
/ # TOKEN=$(curl -k -s --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": 
"test"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F
\" '{print $2}')
/ # 
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




