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

 ```
 [user@rocky9 lab-13]$ helm install consul ./consul-helm
NAME: consul
LAST DEPLOYED: Tue Jan 16 20:26:31 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Consul!

Now that you have deployed Consul, you should look over the docs on using 
Consul with Kubernetes available here: 

https://www.consul.io/docs/platform/k8s/index.html


Your release is named consul.

To learn more about the release, run:

  $ helm status consul
  $ helm get all consul
[user@rocky9 lab-13]$ 
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
[user@rocky9 lab-13]$ helm status vault
NAME: vault
LAST DEPLOYED: Tue Jan 16 20:27:35 2024
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
             Api Address: http://10.112.128.8:8200
                     Cgo: disabled
         Cluster Address: https://vault-0.vault-internal:8201
   Environment Variables: CONSUL_CONSUL_DNS_PORT, CONSUL_CONSUL_DNS_PORT_53_TCP, CONSUL_CONSUL_DNS_PORT_53_TCP_ADDR, CONSUL_CONSUL_DNS_PORT_53_TCP_PORT, CONSUL_CONSUL_DNS_PORT_53_TCP_PROTO, CONSUL_CONSUL_DNS_PORT_53_UDP, CONSUL_CONSUL_DNS_PORT_53_UDP_ADDR, CONSUL_CONSUL_DNS_PORT_53_UDP_PORT, CONSUL_CONSUL_DNS_PORT_53_UDP_PROTO, CONSUL_CONSUL_DNS_SERVICE_HOST, CONSUL_CONSUL_DNS_SERVICE_PORT, CONSUL_CONSUL_DNS_SERVICE_PORT_DNS_TCP, CONSUL_CONSUL_DNS_SERVICE_PORT_DNS_UDP, CONSUL_CONSUL_UI_PORT, CONSUL_CONSUL_UI_PORT_80_TCP, CONSUL_CONSUL_UI_PORT_80_TCP_ADDR, CONSUL_CONSUL_UI_PORT_80_TCP_PORT, CONSUL_CONSUL_UI_PORT_80_TCP_PROTO, CONSUL_CONSUL_UI_SERVICE_HOST, CONSUL_CONSUL_UI_SERVICE_PORT, CONSUL_CONSUL_UI_SERVICE_PORT_HTTP, GODEBUG, HOME, HOSTNAME, HOST_IP, KUBERNETES_PORT, KUBERNETES_PORT_443_TCP, KUBERNETES_PORT_443_TCP_ADDR, KUBERNETES_PORT_443_TCP_PORT, KUBERNETES_PORT_443_TCP_PROTO, KUBERNETES_SERVICE_HOST, KUBERNETES_SERVICE_PORT, KUBERNETES_SERVICE_PORT_HTTPS, NAME, PATH, POD_IP, PWD, SHLVL, SKIP_CHOWN, SKIP_SETCAP, VAULT_ACTIVE_PORT, VAULT_ACTIVE_PORT_8200_TCP, VAULT_ACTIVE_PORT_8200_TCP_ADDR, VAULT_ACTIVE_PORT_8200_TCP_PORT, VAULT_ACTIVE_PORT_8200_TCP_PROTO, VAULT_ACTIVE_PORT_8201_TCP, VAULT_ACTIVE_PORT_8201_TCP_ADDR, VAULT_ACTIVE_PORT_8201_TCP_PORT, VAULT_ACTIVE_PORT_8201_TCP_PROTO, VAULT_ACTIVE_SERVICE_HOST, VAULT_ACTIVE_SERVICE_PORT, VAULT_ACTIVE_SERVICE_PORT_HTTP, VAULT_ACTIVE_SERVICE_PORT_HTTPS_INTERNAL, VAULT_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO, VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS, VAULT_API_ADDR, VAULT_CLUSTER_ADDR, VAULT_K8S_NAMESPACE, VAULT_K8S_POD_NAME, VAULT_PORT, VAULT_PORT_8200_TCP, VAULT_PORT_8200_TCP_ADDR, VAULT_PORT_8200_TCP_PORT, VAULT_PORT_8200_TCP_PROTO, VAULT_PORT_8201_TCP, VAULT_PORT_8201_TCP_ADDR, VAULT_PORT_8201_TCP_PORT, VAULT_PORT_8201_TCP_PROTO, VAULT_SERVICE_HOST, VAULT_SERVICE_PORT, VAULT_SERVICE_PORT_HTTP, VAULT_SERVICE_PORT_HTTPS_INTERNAL, VAULT_STANDBY_PORT, VAULT_STANDBY_PORT_8200_TCP, VAULT_STANDBY_PORT_8200_TCP_ADDR, VAULT_STANDBY_PORT_8200_TCP_PORT, VAULT_STANDBY_PORT_8200_TCP_PROTO, VAULT_STANDBY_PORT_8201_TCP, VAULT_STANDBY_PORT_8201_TCP_ADDR, VAULT_STANDBY_PORT_8201_TCP_PORT, VAULT_STANDBY_PORT_8201_TCP_PROTO, VAULT_STANDBY_SERVICE_HOST, VAULT_STANDBY_SERVICE_PORT, VAULT_STANDBY_SERVICE_PORT_HTTP, VAULT_STANDBY_SERVICE_PORT_HTTPS_INTERNAL, VAULT_UI_PORT, VAULT_UI_PORT_8200_TCP, VAULT_UI_PORT_8200_TCP_ADDR, VAULT_UI_PORT_8200_TCP_PORT, VAULT_UI_PORT_8200_TCP_PROTO, VAULT_UI_SERVICE_HOST, VAULT_UI_SERVICE_PORT, VAULT_UI_SERVICE_PORT_HTTP, VERSION
              Go Version: go1.21.3
              Listener 1: tcp (addr: "[::]:8200", cluster address: "[::]:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: 
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: consul (HA available)
                 Version: Vault v1.15.2, built 2023-11-06T11:33:28Z
             Version Sha: cf1b5cafa047bc8e4a3f93444fcb4011593b92cb

==> Vault server started! Log data will stream in below:

2024-01-16T17:27:56.501Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2024-01-16T17:27:56.501Z [WARN]  storage.consul: appending trailing forward slash to path
2024-01-16T17:27:56.509Z [INFO]  incrementing seal generation: generation=1
2024-01-16T17:27:56.510Z [INFO]  core: Initializing version history cache for core
2024-01-16T17:27:56.510Z [INFO]  events: Starting event system
2024-01-16T17:28:02.958Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:02.958Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T17:28:07.947Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:07.948Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T17:28:12.965Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:12.965Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T17:28:17.947Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:17.947Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T17:28:22.952Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:22.952Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T17:28:27.941Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:27.941Z [INFO]  core: seal configuration missing, not initialized
[user@rocky9 lab-13]$ 
```



---

## Инициализируем vault

* проведите инициализацию через любой под vault'а
```kubectl exec -it vault-0 -- vault operator init --key-shares=5 --key-threshold=3```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator init --key-shares=5 --key-threshold=3
Unseal Key 1: Xsy7G2fZwNuNtxQHXx90gS1T8fL0uLVwRGUCUhWxfrjm
Unseal Key 2: tXZ8gWHyb/5tLBJrLmORzuyZIenqWMIMQQrDMkWKdEls
Unseal Key 3: qPfsHBSp/qZ5fJqyD3tjxu6Ahtllk40eX/9hMg2B2vda
Unseal Key 4: tUx9STgP1Q/JzPE5xeapE7hbLf8mQVssuEopW122N8+8
Unseal Key 5: tvZiBvbIv7XG0bdtcPuRxHvb2aqtQcUan2Nswa0JyUQa

Initial Root Token: hvs.S39d9xe1EEXLTAnvFgz0fuC1

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
Unseal Key 1: Xsy7G2fZwNuNtxQHXx90gS1T8fL0uLVwRGUCUhWxfrjm
Unseal Key 2: tXZ8gWHyb/5tLBJrLmORzuyZIenqWMIMQQrDMkWKdEls
Unseal Key 3: qPfsHBSp/qZ5fJqyD3tjxu6Ahtllk40eX/9hMg2B2vda
Unseal Key 4: tUx9STgP1Q/JzPE5xeapE7hbLf8mQVssuEopW122N8+8
Unseal Key 5: tvZiBvbIv7XG0bdtcPuRxHvb2aqtQcUan2Nswa0JyUQa

Initial Root Token: hvs.S39d9xe1EEXLTAnvFgz0fuC1
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
             Api Address: http://10.112.128.8:8200
                     Cgo: disabled
         Cluster Address: https://vault-0.vault-internal:8201
   Environment Variables: CONSUL_CONSUL_DNS_PORT, CONSUL_CONSUL_DNS_PORT_53_TCP, CONSUL_CONSUL_DNS_PORT_53_TCP_ADDR, CONSUL_CONSUL_DNS_PORT_53_TCP_PORT, CONSUL_CONSUL_DNS_PORT_53_TCP_PROTO, CONSUL_CONSUL_DNS_PORT_53_UDP, CONSUL_CONSUL_DNS_PORT_53_UDP_ADDR, CONSUL_CONSUL_DNS_PORT_53_UDP_PORT, CONSUL_CONSUL_DNS_PORT_53_UDP_PROTO, CONSUL_CONSUL_DNS_SERVICE_HOST, CONSUL_CONSUL_DNS_SERVICE_PORT, CONSUL_CONSUL_DNS_SERVICE_PORT_DNS_TCP, CONSUL_CONSUL_DNS_SERVICE_PORT_DNS_UDP, CONSUL_CONSUL_UI_PORT, CONSUL_CONSUL_UI_PORT_80_TCP, CONSUL_CONSUL_UI_PORT_80_TCP_ADDR, CONSUL_CONSUL_UI_PORT_80_TCP_PORT, CONSUL_CONSUL_UI_PORT_80_TCP_PROTO, CONSUL_CONSUL_UI_SERVICE_HOST, CONSUL_CONSUL_UI_SERVICE_PORT, CONSUL_CONSUL_UI_SERVICE_PORT_HTTP, GODEBUG, HOME, HOSTNAME, HOST_IP, KUBERNETES_PORT, KUBERNETES_PORT_443_TCP, KUBERNETES_PORT_443_TCP_ADDR, KUBERNETES_PORT_443_TCP_PORT, KUBERNETES_PORT_443_TCP_PROTO, KUBERNETES_SERVICE_HOST, KUBERNETES_SERVICE_PORT, KUBERNETES_SERVICE_PORT_HTTPS, NAME, PATH, POD_IP, PWD, SHLVL, SKIP_CHOWN, SKIP_SETCAP, VAULT_ACTIVE_PORT, VAULT_ACTIVE_PORT_8200_TCP, VAULT_ACTIVE_PORT_8200_TCP_ADDR, VAULT_ACTIVE_PORT_8200_TCP_PORT, VAULT_ACTIVE_PORT_8200_TCP_PROTO, VAULT_ACTIVE_PORT_8201_TCP, VAULT_ACTIVE_PORT_8201_TCP_ADDR, VAULT_ACTIVE_PORT_8201_TCP_PORT, VAULT_ACTIVE_PORT_8201_TCP_PROTO, VAULT_ACTIVE_SERVICE_HOST, VAULT_ACTIVE_SERVICE_PORT, VAULT_ACTIVE_SERVICE_PORT_HTTP, VAULT_ACTIVE_SERVICE_PORT_HTTPS_INTERNAL, VAULT_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT, VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO, VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT, VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS, VAULT_API_ADDR, VAULT_CLUSTER_ADDR, VAULT_K8S_NAMESPACE, VAULT_K8S_POD_NAME, VAULT_PORT, VAULT_PORT_8200_TCP, VAULT_PORT_8200_TCP_ADDR, VAULT_PORT_8200_TCP_PORT, VAULT_PORT_8200_TCP_PROTO, VAULT_PORT_8201_TCP, VAULT_PORT_8201_TCP_ADDR, VAULT_PORT_8201_TCP_PORT, VAULT_PORT_8201_TCP_PROTO, VAULT_SERVICE_HOST, VAULT_SERVICE_PORT, VAULT_SERVICE_PORT_HTTP, VAULT_SERVICE_PORT_HTTPS_INTERNAL, VAULT_STANDBY_PORT, VAULT_STANDBY_PORT_8200_TCP, VAULT_STANDBY_PORT_8200_TCP_ADDR, VAULT_STANDBY_PORT_8200_TCP_PORT, VAULT_STANDBY_PORT_8200_TCP_PROTO, VAULT_STANDBY_PORT_8201_TCP, VAULT_STANDBY_PORT_8201_TCP_ADDR, VAULT_STANDBY_PORT_8201_TCP_PORT, VAULT_STANDBY_PORT_8201_TCP_PROTO, VAULT_STANDBY_SERVICE_HOST, VAULT_STANDBY_SERVICE_PORT, VAULT_STANDBY_SERVICE_PORT_HTTP, VAULT_STANDBY_SERVICE_PORT_HTTPS_INTERNAL, VAULT_UI_PORT, VAULT_UI_PORT_8200_TCP, VAULT_UI_PORT_8200_TCP_ADDR, VAULT_UI_PORT_8200_TCP_PORT, VAULT_UI_PORT_8200_TCP_PROTO, VAULT_UI_SERVICE_HOST, VAULT_UI_SERVICE_PORT, VAULT_UI_SERVICE_PORT_HTTP, VERSION
              Go Version: go1.21.3
              Listener 1: tcp (addr: "[::]:8200", cluster address: "[::]:8201", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")
               Log Level: 
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: consul (HA available)
                 Version: Vault v1.15.2, built 2023-11-06T11:33:28Z
             Version Sha: cf1b5cafa047bc8e4a3f93444fcb4011593b92cb

==> Vault server started! Log data will stream in below:

2024-01-16T17:27:56.501Z [INFO]  proxy environment: http_proxy="" https_proxy="" no_proxy=""
2024-01-16T17:27:56.501Z [WARN]  storage.consul: appending trailing forward slash to path
2024-01-16T17:27:56.509Z [INFO]  incrementing seal generation: generation=1
2024-01-16T17:27:56.510Z [INFO]  core: Initializing version history cache for core
2024-01-16T17:27:56.510Z [INFO]  events: Starting event system
2024-01-16T17:28:02.958Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:02.958Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T17:28:07.947Z [INFO]  core: security barrier not initialized
2024-01-16T17:28:07.948Z [INFO]  core: seal configuration missing, not initialized
...
2024-01-16T17:46:39.704Z [INFO]  core: security barrier not initialized
2024-01-16T17:46:39.704Z [INFO]  core: seal configuration missing, not initialized
2024-01-16T17:46:39.705Z [INFO]  core: security barrier not initialized
2024-01-16T17:46:39.748Z [INFO]  core: security barrier initialized: stored=1 shares=5 threshold=3
2024-01-16T17:46:39.835Z [INFO]  core: post-unseal setup starting
2024-01-16T17:46:39.850Z [INFO]  core: loaded wrapping token key
2024-01-16T17:46:39.850Z [INFO]  core: successfully setup plugin runtime catalog
2024-01-16T17:46:39.850Z [INFO]  core: successfully setup plugin catalog: plugin-directory=""
2024-01-16T17:46:39.851Z [INFO]  core: no mounts; adding default mount table
2024-01-16T17:46:39.872Z [INFO]  core: successfully mounted: type=cubbyhole version="v1.15.2+builtin.vault" path=cubbyhole/ namespace="ID: root. Path: "
2024-01-16T17:46:39.872Z [INFO]  core: successfully mounted: type=system version="v1.15.2+builtin.vault" path=sys/ namespace="ID: root. Path: "
2024-01-16T17:46:39.873Z [INFO]  core: successfully mounted: type=identity version="v1.15.2+builtin.vault" path=identity/ namespace="ID: root. Path: "
2024-01-16T17:46:39.970Z [INFO]  core: successfully mounted: type=token version="v1.15.2+builtin.vault" path=token/ namespace="ID: root. Path: "
2024-01-16T17:46:40.039Z [INFO]  rollback: Starting the rollback manager with 256 workers
2024-01-16T17:46:40.040Z [INFO]  rollback: starting rollback manager
2024-01-16T17:46:40.040Z [INFO]  core: restoring leases
2024-01-16T17:46:40.041Z [INFO]  expiration: lease restore complete
2024-01-16T17:46:40.068Z [INFO]  identity: entities restored
2024-01-16T17:46:40.068Z [INFO]  identity: groups restored
2024-01-16T17:46:40.070Z [INFO]  core: usage gauge collection is disabled
2024-01-16T17:46:40.080Z [INFO]  core: Recorded vault version: vault version=1.15.2 upgrade time="2024-01-16 17:46:40.069974673 +0000 UTC" build date=2023-11-06T11:33:28Z
2024-01-16T17:46:40.659Z [INFO]  core: post-unseal setup complete
2024-01-16T17:46:40.713Z [INFO]  core: root token generated
2024-01-16T17:46:40.713Z [INFO]  core: pre-seal teardown starting
2024-01-16T17:46:40.713Z [INFO]  rollback: stopping rollback manager
2024-01-16T17:46:40.713Z [INFO]  core: pre-seal teardown complete
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
Storage Type       consul
HA Enabled         true
command terminated with exit code 2
[user@rocky9 lab-13]$ 
```

---

## Распечатаем  vault

* Обратите внимание на переменные окружения в подах

```bash
 kubectl exec -it vault-0 -- env | grep VAULT
 VAULT_ADDR=http://127.0.0.1:8200
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- env | grep VAULT
VAULT_K8S_POD_NAME=vault-0
VAULT_CLUSTER_ADDR=https://vault-0.vault-internal:8201
VAULT_API_ADDR=http://10.112.128.8:8200
VAULT_K8S_NAMESPACE=default
VAULT_ADDR=http://127.0.0.1:8200
VAULT_ACTIVE_PORT_8201_TCP_PORT=8201
VAULT_STANDBY_PORT=tcp://10.96.131.169:8200
VAULT_STANDBY_PORT_8200_TCP_PROTO=tcp
VAULT_SERVICE_HOST=10.96.137.143
VAULT_UI_PORT=tcp://10.96.214.88:8200
VAULT_ACTIVE_PORT_8200_TCP=tcp://10.96.252.96:8200
VAULT_STANDBY_PORT_8201_TCP_PROTO=tcp
VAULT_SERVICE_PORT=8200
VAULT_STANDBY_SERVICE_PORT_HTTP=8200
VAULT_PORT_8200_TCP_PORT=8200
VAULT_PORT_8201_TCP_PROTO=tcp
VAULT_PORT_8201_TCP_PORT=8201
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT=443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR=10.96.189.21
VAULT_ACTIVE_SERVICE_PORT=8200
VAULT_PORT=tcp://10.96.137.143:8200
VAULT_ACTIVE_SERVICE_HOST=10.96.252.96
VAULT_SERVICE_PORT_HTTP=8200
VAULT_STANDBY_PORT_8201_TCP=tcp://10.96.131.169:8201
VAULT_AGENT_INJECTOR_SVC_PORT=tcp://10.96.189.21:443
VAULT_ACTIVE_PORT_8201_TCP=tcp://10.96.252.96:8201
VAULT_UI_SERVICE_PORT=8200
VAULT_ACTIVE_PORT=tcp://10.96.252.96:8200
VAULT_ACTIVE_PORT_8201_TCP_PROTO=tcp
VAULT_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_UI_PORT_8200_TCP_PROTO=tcp
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS=443
VAULT_ACTIVE_PORT_8200_TCP_ADDR=10.96.252.96
VAULT_UI_PORT_8200_TCP_ADDR=10.96.214.88
VAULT_ACTIVE_SERVICE_PORT_HTTP=8200
VAULT_STANDBY_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_STANDBY_PORT_8200_TCP_ADDR=10.96.131.169
VAULT_PORT_8201_TCP=tcp://10.96.137.143:8201
VAULT_PORT_8201_TCP_ADDR=10.96.137.143
VAULT_ACTIVE_PORT_8200_TCP_PROTO=tcp
VAULT_ACTIVE_PORT_8201_TCP_ADDR=10.96.252.96
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP=tcp://10.96.189.21:443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO=tcp
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT=443
VAULT_ACTIVE_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_ACTIVE_PORT_8200_TCP_PORT=8200
VAULT_UI_SERVICE_HOST=10.96.214.88
VAULT_STANDBY_PORT_8201_TCP_ADDR=10.96.131.169
VAULT_STANDBY_PORT_8200_TCP=tcp://10.96.131.169:8200
VAULT_STANDBY_PORT_8201_TCP_PORT=8201
VAULT_PORT_8200_TCP=tcp://10.96.137.143:8200
VAULT_UI_SERVICE_PORT_HTTP=8200
VAULT_STANDBY_SERVICE_HOST=10.96.131.169
VAULT_PORT_8200_TCP_PROTO=tcp
VAULT_UI_PORT_8200_TCP_PORT=8200
VAULT_STANDBY_SERVICE_PORT=8200
VAULT_UI_PORT_8200_TCP=tcp://10.96.214.88:8200
VAULT_STANDBY_PORT_8200_TCP_PORT=8200
VAULT_PORT_8200_TCP_ADDR=10.96.137.143
VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST=10.96.189.21
[user@rocky9 lab-13]$ 
```

*  Распечатать нужно каждый под 



```bash
kubectl exec -it vault-0 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-1 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-2 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
```

``
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'Xsy7G2fZwNuNtxQHXx90gS1T8fL0uLVwRGUCUhWxfrjm'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       b4d29b83-78e8-5778-ccdd-cab8feeb4811
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       consul
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'tXZ8gWHyb/5tLBJrLmORzuyZIenqWMIMQQrDMkWKdEls'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       b4d29b83-78e8-5778-ccdd-cab8feeb4811
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       consul
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'qPfsHBSp/qZ5fJqyD3tjxu6Ahtllk40eX/9hMg2B2vda'
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.15.2
Build Date      2023-11-06T11:33:28Z
Storage Type    consul
Cluster Name    vault-cluster-b19dcecc
Cluster ID      b45344c6-3506-be6d-b88b-b326660cf3d0
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
Active Since    2024-01-16T17:54:46.44054218Z
[user@rocky9 lab-13]$ 
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-1 -- vault operator unseal 'Xsy7G2fZwNuNtxQHXx90gS1T8fL0uLVwRGUCUhWxfrjm'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       a1222984-c554-2137-ac72-4bb1ffbec2c9
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       consul
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-1 -- vault operator unseal 'tXZ8gWHyb/5tLBJrLmORzuyZIenqWMIMQQrDMkWKdEls'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       a1222984-c554-2137-ac72-4bb1ffbec2c9
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       consul
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-1 -- vault operator unseal 'qPfsHBSp/qZ5fJqyD3tjxu6Ahtllk40eX/9hMg2B2vda'
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           5
Threshold              3
Version                1.15.2
Build Date             2023-11-06T11:33:28Z
Storage Type           consul
Cluster Name           vault-cluster-b19dcecc
Cluster ID             b45344c6-3506-be6d-b88b-b326660cf3d0
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.112.128.8:8200
[user@rocky9 lab-13]$ 
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-2 -- vault operator unseal 'Xsy7G2fZwNuNtxQHXx90gS1T8fL0uLVwRGUCUhWxfrjm'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       c3446bb0-4333-6351-9943-fad69b88a732
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       consul
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-2 -- vault operator unseal 'tXZ8gWHyb/5tLBJrLmORzuyZIenqWMIMQQrDMkWKdEls'
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       c3446bb0-4333-6351-9943-fad69b88a732
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       consul
HA Enabled         true
[user@rocky9 lab-13]$ kubectl exec -it vault-2 -- vault operator unseal 'qPfsHBSp/qZ5fJqyD3tjxu6Ahtllk40eX/9hMg2B2vda'
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           5
Threshold              3
Version                1.15.2
Build Date             2023-11-06T11:33:28Z
Storage Type           consul
Cluster Name           vault-cluster-b19dcecc
Cluster ID             b45344c6-3506-be6d-b88b-b326660cf3d0
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.112.128.8:8200
[user@rocky9 lab-13]$ 
```


* добавьте выдачу ```vault status```  в README.md 

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.15.2
Build Date      2023-11-06T11:33:28Z
Storage Type    consul
Cluster Name    vault-cluster-b19dcecc
Cluster ID      b45344c6-3506-be6d-b88b-b326660cf3d0
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
Active Since    2024-01-16T17:54:46.44054218Z
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-1 -- vault status
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           5
Threshold              3
Version                1.15.2
Build Date             2023-11-06T11:33:28Z
Storage Type           consul
Cluster Name           vault-cluster-b19dcecc
Cluster ID             b45344c6-3506-be6d-b88b-b326660cf3d0
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.112.128.8:8200
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-2 -- vault status
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           5
Threshold              3
Version                1.15.2
Build Date             2023-11-06T11:33:28Z
Storage Type           consul
Cluster Name           vault-cluster-b19dcecc
Cluster ID             b45344c6-3506-be6d-b88b-b326660cf3d0
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.112.128.8:8200
[user@rocky9 lab-13]$ 
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
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault auth list
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
token                hvs.S39d9xe1EEXLTAnvFgz0fuC1
token_accessor       awM0XRV1aIYmDzVFpC0U5BP9
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
kubectl exec -it vault-0 -- vault auth list
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault auth list
Path      Type     Accessor               Description                Version
----      ----     --------               -----------                -------
token/    token    auth_token_3cdd5f14    token based credentials    n/a
[user@rocky9 lab-13]$ 
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
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
Success! Enabled the kv secrets engine at: otus/
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault secrets list --detailed
Path          Plugin       Accessor              Default TTL    Max TTL    Force No Cache    Replication    Seal Wrap    External Entropy Access    Options    Description                                                UUID                                    Version    Running Version          Running SHA256    Deprecation Status
----          ------       --------              -----------    -------    --------------    -----------    ---------    -----------------------    -------    -----------                                                ----                                    -------    ---------------          --------------    ------------------
cubbyhole/    cubbyhole    cubbyhole_0d0e5080    n/a            n/a        false             local          false        false                      map[]      per-token private secret storage                           86d82095-8fcf-4351-1ef6-f39490eaaec6    n/a        v1.15.2+builtin.vault    n/a               n/a
identity/     identity     identity_3de25df9     system         system     false             replicated     false        false                      map[]      identity store                                             f3c222c7-c508-9770-1469-a5ee0d912b94    n/a        v1.15.2+builtin.vault    n/a               n/a
otus/         kv           kv_6c46427d           system         system     false             replicated     false        false                      map[]      n/a                                                        b9139d6e-d6e6-c06a-37a2-06fa88abfff5    n/a        v0.16.1+builtin          n/a               supported
sys/          system       system_eed4f82b       n/a            n/a        false             replicated     true         false                      map[]      system endpoints used for control, policy and debugging    3a50dec2-c0bc-a9f7-61ca-8eae814b9bd7    n/a        v1.15.2+builtin.vault    n/a               n/a
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='h7sgm4j9ztp'
Success! Data written to: otus/otus-ro/config
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='h7sgm4j9ztp'
Success! Data written to: otus/otus-rw/config
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
Key                 Value
---                 -----
refresh_interval    768h
password            h7sgm4j9ztp
username            otus
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
====== Data ======
Key         Value
---         -----
password    h7sgm4j9ztp
username    otus
[user@rocky9 lab-13]$ 
```


* выыод команды чтения секрета добавить в README.md

---

##  Включим авторизацию через k8s
```bash
kubectl exec -it vault-0 -- vault auth enable kubernetes
kubectl exec -it vault-0 -- vault auth list
```

```
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault auth enable kubernetes
Success! Enabled kubernetes auth method at: kubernetes/
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault auth list
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_5c8e911f    n/a                        n/a
token/         token         auth_token_3cdd5f14         token based credentials    n/a
[user@rocky9 lab-13]$ 
```

* Обновленный список авторизаций - добавить в README.md

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
$ kubectl apply -f ./vault-auth-service-account.yml
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
export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g' )
```

```
[user@rocky9 lab-13]$ export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')
[user@rocky9 lab-13]$ 
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

## создадим политику и роль в vault 

```
kubectl cp otus-policy.hcl vault-0:/tmp/

kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl

kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
```

```
[user@rocky9 lab-13]$ kubectl cp otus-policy.hcl vault-0:/tmp/
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
Success! Uploaded policy: otus-policy
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
Success! Data written to: auth/kubernetes/role/otus
[user@rocky9 lab-13]$ 
```

---

## Проверим как работает авторизация

* Создадим под с привязанным сервис аккоунтом и установим туда curl и jq

```bash
kubectl run --generator=run-pod/v1 tmp --rm -i --tty --serviceaccount=vault-auth --image alpine:3.7
apk add curl jq
```

```
[user@rocky9 lab-13]$ kubectl run tmp --rm -i --tty --image alpine:3.7 --overrides='{ "spec": { "serviceAccount": "vault-auth" }  }'
If you don't see a command prompt, try pressing enter.
/ # 
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
/ # 
/ # KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
/ # 
/ # curl --request POST  --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0{
  "request_id": "e83b7a8a-8d0c-7bf5-76cb-2f8e1c4929af",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": null,
  "auth": {
    "client_token": "hvs.CAESIPa5XmJ0JPrkaEZBj31uhUcqiJ12kG0XvEtxVND3SA2eGh4KHGh2cy5YRzNpVUJiN0FUWEVodHA5QnluVUphRWU",
    "accessor": "o3UQ0ZVhlAGEm6aYY6q4FpDm",
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
      "service_account_uid": "f1d7e441-c410-41cb-ac9f-51dc6085536a"
    },
    "lease_duration": 86400,
    "renewable": true,
    "entity_id": "e215fb49-f409-1bda-f409-e587a95c625d",
    "token_type": "service",
    "orphan": true,
    "mfa_requirement": null,
    "num_uses": 0
  }
}
100  1714  100   749  100   965   7271   9368 --:--:-- --:--:-- --:--:-- 16640
/ # 
/ # TOKEN=$(curl -k -s --request POST --data '{"jwt": "'$KUBE_TOKEN'", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq '.auth.client_token' | awk -F\" '{print $2}')
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

```
/ # curl --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-ro/config
{"request_id":"4216cba9-8d22-098b-1f61-9fcf8ad2cd3c","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"h7sgm4j9ztp","username":"otus"},"wrap_info":null,"warnings":null,"auth":null}
/ # 
/ # curl --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config
{"request_id":"52d8847f-3cfa-4b40-04bd-48f08fe275f5","lease_id":"","renewable":false,"lease_duration":2764800,"data":{"password":"h7sgm4j9ztp","username":"otus"},"wrap_info":null,"warnings":null,"auth":null}
/ # 
```

* проверим запись
```bash
curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-ro/config
curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-rw/config
curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:s.pPjvLHcbKsNoWo7zAAuhMoVK" $VAULT_ADDR/v1/otus/otus-rw/config1
```

```
/ # curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-ro/config
{"errors":["1 error occurred:\n\t* permission denied\n\n"]}
/ # 
/ # curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config
{"errors":["1 error occurred:\n\t* permission denied\n\n"]}
/ # 
/ # curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config1
/ # 
```

---

## Разберемся с ошибками при записи
* Почему мы смогли записать otus-rw/config1 но не смогли otus-rw/config
* Измените политику так, чтобы можно было менять otus-rw/config
* Ответы на вопросы добавить в README.md


Мы смогли записать otus-rw/config1, но не смогли otus-rw/config, так как в политике роли otus/otus-rw 'read', 'create', 'list'.
Для того чтобы была возможность записать otus-rw/config, добавим в политику 'update'.

В новом терминале создадим новый файл otus-policy1.hcl и обновим политику в Vault:
```
[user@rocky9 lab-13]$ tee otus-policy1.hcl <<EOF
path "otus/otus-ro/*" {
  capabilities = ["read", "list"]
}

path "otus/otus-rw/*" {
  capabilities = ["read", "update", "create", "list"]
}
EOF
path "otus/otus-ro/*" {
  capabilities = ["read", "list"]
}

path "otus/otus-rw/*" {
  capabilities = ["read", "update", "create", "list"]
}
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl cp ./otus-policy1.hcl vault-0:/tmp/
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy1.hcl
Success! Uploaded policy: otus-policy
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
Success! Data written to: auth/kubernetes/role/otus
[user@rocky9 lab-13]$ 
```

Снова проверим запись otus-rw/config в поде tmp:
```
/ # curl --request POST --data '{"bar": "baz"}'   --header "X-Vault-Token:$TOKEN" $VAULT_ADDR/v1/otus/otus-rw/config
/ # 
```

---

##  Use case использования авторизации через кубер

* Авторизуемся через vault-agent и получим клиентский токен
* Через consul-template достанем секрет и положим его в nginx
* Итог - nginx получил секрет из волта, не зная ничего про волт


---

##  Заберем репозиторий с примерами

```bash 
git clone https://github.com/hashicorp/vault-guides.git
cd ./vault-guides/identity/vault-agent-k8s-demo
```
* В каталоге configs-k8s скорректируйте конфиги с учетом ранее созданых ролей и секретов
* Проверьте и скорректируйте конфиг example-k8s-spec.yml
* Скорректированные конфиги приложить к ДЗ

---

##  Запускаем пример

```bash
    # Create a ConfigMap, example-vault-agent-config
    #$ kubectl create configmap example-vault-agent-config --from-file=./configs-k8s/
    $ kubectl create configmap example-vault-agent-config --from-file=./configmap.yaml

    # View the created ConfigMap
    $ kubectl get configmap example-vault-agent-config -o yaml

    # Finally, create vault-agent-example Pod
    $ kubectl apply -f example-k8s-spec.yaml --record
```

```
[user@rocky9 vault-agent-k8s-demo]$ kubectl create configmap example-vault-agent-config --from-file=./configmap.yaml
configmap/example-vault-agent-config created
[user@rocky9 vault-agent-k8s-demo]$ 
```

```
[user@rocky9 vault-agent-k8s-demo]$ kubectl get configmap example-vault-agent-config -o yaml
apiVersion: v1
data:
  configmap.yaml: |
    apiVersion: v1
    data:
      vault-agent-config.hcl: |
        # Comment this out if running as sidecar instead of initContainer
        exit_after_auth = true

        pid_file = "/home/vault/pidfile"

        auto_auth {
            method "kubernetes" {
                mount_path = "auth/kubernetes"
                config = {
                    role = "example"
                }
            }

            sink "file" {
                config = {
                    path = "/home/vault/.vault-token"
                }
            }
        }

        template {
        destination = "/etc/secrets/index.html"
        contents = <<EOT
        <html>
        <body>
        <p>Some secrets:</p>
        {{- with secret "secret/data/myapp/config" }}
        <ul>
        <li><pre>username: {{ .Data.data.username }}</pre></li>
        <li><pre>password: {{ .Data.data.password }}</pre></li>
        </ul>
        {{ end }}
        </body>
        </html>
        EOT
        }
    kind: ConfigMap
    metadata:
      name: example-vault-agent-config
      namespace: default
kind: ConfigMap
metadata:
  creationTimestamp: "2024-01-16T20:01:53Z"
  name: example-vault-agent-config
  namespace: default
  resourceVersion: "44437"
  uid: 8a6ea294-efce-4584-8b44-ec943cb69b81
[user@rocky9 vault-agent-k8s-demo]$ 
```

```
[user@rocky9 vault-agent-k8s-demo]$ kubectl apply -f ./example-k8s-spec.yaml --record
Flag --record has been deprecated, --record will be removed in the future
pod/vault-agent-example created
[user@rocky9 vault-agent-k8s-demo]$ 
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
* Создадим роль для выдачи сертификатов
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




