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
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator init --key-shares=1 --key-threshold=1
Unseal Key 1: F6KsHvN7Gc4BQnA+++GQ/HCzilfCtsJn6YbYAmBQv5s=

Initial Root Token: hvs.ckAMilH493UGx7W6qOAT8kx0

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated root key. Without at least 1 keys to
reconstruct the root key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
[user@rocky9 lab-13]$
```

* сохраните ключи, полученные при инициализации
```
Unseal Key 1: qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A=

Initial Root Token: s.KZmV3wbjEJabNtcwJWIlOfSj
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
2024-01-11T18:39:05.131Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:05.131Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:10.195Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:10.195Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:15.138Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:15.139Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:20.127Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:20.127Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:25.172Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:25.172Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:30.111Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:30.111Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:35.127Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:35.127Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:40.221Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:40.221Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:45.110Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:45.110Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:50.111Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:50.111Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:55.185Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:55.185Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:39:55.742Z [INFO]  core: security barrier not initialized
2024-01-11T18:39:55.742Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:00.114Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:00.114Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:05.226Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:05.226Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:10.155Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:10.155Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:15.253Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:15.253Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:20.126Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:20.126Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:25.111Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:25.111Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:30.119Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:30.119Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:35.192Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:35.192Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:40.156Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:40.156Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:45.172Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:45.172Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:50.169Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:50.169Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:40:55.124Z [INFO]  core: security barrier not initialized
2024-01-11T18:40:55.124Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:00.131Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:00.131Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:05.137Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:05.137Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:10.116Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:10.116Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:11.808Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:11.808Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:15.101Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:15.101Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:20.125Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:20.125Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:25.125Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:25.125Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:30.125Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:30.125Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:35.124Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:35.124Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:40.174Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:40.174Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:45.138Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:45.138Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:50.200Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:50.200Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:41:55.118Z [INFO]  core: security barrier not initialized
2024-01-11T18:41:55.118Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:00.113Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:00.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:05.141Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:05.141Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:10.131Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:10.131Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:15.132Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:15.132Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:20.135Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:20.135Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:21.714Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:21.714Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:25.127Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:25.128Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:30.116Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:30.116Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:35.199Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:35.199Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:40.194Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:40.194Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:45.123Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:45.124Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:50.196Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:50.196Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:42:55.149Z [INFO]  core: security barrier not initialized
2024-01-11T18:42:55.149Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:00.098Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:00.098Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:05.170Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:05.170Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:10.246Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:10.246Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:15.127Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:15.127Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:20.245Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:20.245Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:24.733Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:24.733Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:25.188Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:25.189Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:30.206Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:30.207Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:35.119Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:35.119Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:40.186Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:40.186Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:45.127Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:45.127Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:50.143Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:50.143Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:43:55.125Z [INFO]  core: security barrier not initialized
2024-01-11T18:43:55.125Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:00.197Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:00.197Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:05.118Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:05.118Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:10.134Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:10.134Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:15.126Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:15.126Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:20.227Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:20.227Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:25.130Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:25.131Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:30.158Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:30.158Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:35.154Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:35.154Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:40.195Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:40.195Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:42.714Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:42.714Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:45.181Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:45.181Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:50.115Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:50.115Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:44:55.113Z [INFO]  core: security barrier not initialized
2024-01-11T18:44:55.113Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:45:00.116Z [INFO]  core: security barrier not initialized
2024-01-11T18:45:00.116Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:45:05.130Z [INFO]  core: security barrier not initialized
2024-01-11T18:45:05.130Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:45:09.752Z [INFO]  core: security barrier not initialized
2024-01-11T18:45:09.752Z [INFO]  core: seal configuration missing, not initialized
2024-01-11T18:45:09.753Z [INFO]  core: security barrier not initialized
2024-01-11T18:45:09.753Z [INFO]  core: security barrier initialized: stored=1 shares=1 threshold=1
2024-01-11T18:45:09.755Z [INFO]  core: post-unseal setup starting
2024-01-11T18:45:09.765Z [INFO]  core: loaded wrapping token key
2024-01-11T18:45:09.765Z [INFO]  core: successfully setup plugin runtime catalog
2024-01-11T18:45:09.766Z [INFO]  core: successfully setup plugin catalog: plugin-directory=""
2024-01-11T18:45:09.767Z [INFO]  core: no mounts; adding default mount table
2024-01-11T18:45:09.770Z [INFO]  core: successfully mounted: type=cubbyhole version="v1.15.2+builtin.vault" path=cubbyhole/ namespace="ID: root. Path: "
2024-01-11T18:45:09.771Z [INFO]  core: successfully mounted: type=system version="v1.15.2+builtin.vault" path=sys/ namespace="ID: root. Path: "
2024-01-11T18:45:09.772Z [INFO]  core: successfully mounted: type=identity version="v1.15.2+builtin.vault" path=identity/ namespace="ID: root. Path: "
2024-01-11T18:45:09.775Z [INFO]  core: successfully mounted: type=token version="v1.15.2+builtin.vault" path=token/ namespace="ID: root. Path: "
2024-01-11T18:45:09.776Z [INFO]  rollback: Starting the rollback manager with 256 workers
2024-01-11T18:45:09.776Z [INFO]  rollback: starting rollback manager
2024-01-11T18:45:09.776Z [INFO]  core: restoring leases
2024-01-11T18:45:09.777Z [INFO]  expiration: lease restore complete
2024-01-11T18:45:09.778Z [INFO]  identity: entities restored
2024-01-11T18:45:09.778Z [INFO]  identity: groups restored
2024-01-11T18:45:09.778Z [INFO]  core: usage gauge collection is disabled
2024-01-11T18:45:09.779Z [INFO]  core: Recorded vault version: vault version=1.15.2 upgrade time="2024-01-11 18:45:09.778655546 +0000 UTC" build date=2023-11-06T11:33:28Z
2024-01-11T18:45:10.392Z [INFO]  core: post-unseal setup complete
2024-01-11T18:45:10.393Z [INFO]  core: root token generated
2024-01-11T18:45:10.393Z [INFO]  core: pre-seal teardown starting
2024-01-11T18:45:10.393Z [INFO]  rollback: stopping rollback manager
2024-01-11T18:45:10.394Z [INFO]  core: pre-seal teardown complete
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
Total Shares       1
Threshold          1
Unseal Progress    0/1
Unseal Nonce       n/a
Version            1.15.2
Build Date         2023-11-06T11:33:28Z
Storage Type       file
HA Enabled         false
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
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- env | grep VAULT
VAULT_K8S_POD_NAME=vault-0
VAULT_K8S_NAMESPACE=default
VAULT_API_ADDR=http://10.244.0.4:8200
VAULT_CLUSTER_ADDR=https://vault-0.vault-internal:8201
VAULT_ADDR=http://127.0.0.1:8200
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_ADDR=10.108.226.101
VAULT_SERVICE_PORT=8200
VAULT_PORT_8200_TCP_PORT=8200
VAULT_AGENT_INJECTOR_SVC_PORT=tcp://10.108.226.101:443
VAULT_PORT=tcp://10.98.62.126:8200
VAULT_PORT_8201_TCP_PROTO=tcp
VAULT_PORT_8200_TCP_ADDR=10.98.62.126
VAULT_PORT_8201_TCP_ADDR=10.98.62.126
VAULT_AGENT_INJECTOR_SVC_SERVICE_HOST=10.108.226.101
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT=443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PROTO=tcp
VAULT_SERVICE_PORT_HTTPS_INTERNAL=8201
VAULT_PORT_8201_TCP=tcp://10.98.62.126:8201
VAULT_AGENT_INJECTOR_SVC_SERVICE_PORT_HTTPS=443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP=tcp://10.108.226.101:443
VAULT_AGENT_INJECTOR_SVC_PORT_443_TCP_PORT=443
VAULT_SERVICE_HOST=10.98.62.126
VAULT_SERVICE_PORT_HTTP=8200
VAULT_PORT_8200_TCP=tcp://10.98.62.126:8200
VAULT_PORT_8200_TCP_PROTO=tcp
VAULT_PORT_8201_TCP_PORT=8201
[user@rocky9 lab-13]$
```

*  Распечатать нужно каждый под 



```bash
kubectl exec -it vault-0 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-1 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
kubectl exec -it vault-2 -- vault operator unseal 'qpt7e1w2D2tQqPdknR8A5VFrzFZ0Yz6W/BPoFMX5x2A='
```

``
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault operator unseal 'F6KsHvN7Gc4BQnA+++GQ/HCzilfCtsJn6YbYAmBQv5s='
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.15.2
Build Date      2023-11-06T11:33:28Z
Storage Type    file
Cluster Name    vault-cluster-33c5f7f9
Cluster ID      0607736e-7bf8-1b68-37d2-d2fa9a59581c
HA Enabled      false
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
[user@rocky9 lab-13]$ kubectl exec -it vault-0 --  vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.ckAMilH493UGx7W6qOAT8kx0
token_accessor       987rRVUjVLMJMRVBTamStbZz
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
[user@rocky9 lab-13]$ kubectl exec -it vault-0 --  vault auth list
Path      Type     Accessor               Description                Version
----      ----     --------               -----------                -------
token/    token    auth_token_f48156ef    token based credentials    n/a
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
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault secrets list --detailed
Path          Plugin       Accessor              Default TTL    Max TTL    Force No Cache    Replication    Seal Wrap    External Entropy Access    Options    Description                                                UUID                                    Version    Running Version          Running SHA256    Deprecation Status
----          ------       --------              -----------    -------    --------------    -----------    ---------    -----------------------    -------    -----------                                                ----                                    -------    ---------------          --------------    ------------------
cubbyhole/    cubbyhole    cubbyhole_210f1db3    n/a            n/a        false             local          false        false                      map[]      per-token private secret storage                           1d64970b-2199-824c-b73e-d42c4ca3b326    n/a        v1.15.2+builtin.vault    n/a               n/a
identity/     identity     identity_94ffa7c6     system         system     false             replicated     false        false                      map[]      identity store                                             08eb3be2-0186-e1fa-3ff7-7e63fa7f00df    n/a        v1.15.2+builtin.vault    n/a               n/a
otus/         kv           kv_1b274113           system         system     false             replicated     false        false                      map[]      n/a                                                        e3242ed6-4524-ca5c-52ce-eba064896f95    n/a        v0.16.1+builtin          n/a               supported
sys/          system       system_c70ea374       n/a            n/a        false             replicated     true         false                      map[]      system endpoints used for control, policy and debugging    746e3ace-5cf8-c8d0-fc3c-9ab8f68fd325    n/a        v1.15.2+builtin.vault    n/a               n/a
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs'
Success! Data written to: otus/otus-ro/config
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault read otus/otus-ro/config
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config
No value found at otus/otus-rw/config
command terminated with exit code 2
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
[user@rocky9 lab-13]$ 
[user@rocky9 lab-13]$ kubectl exec -it vault-0 --  vault auth list
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_2702815f    n/a                        n/a
token/         token         auth_token_f48156ef         token based credentials    n/a
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
[user@rocky9 lab-13]$ kubectl apply -f vault-auth-service-account.yml
error: resource mapping not found for name: "role-tokenreview-binding" namespace: "default" from "vault-auth-service-account.yml": no matches for kind "ClusterRoleBinding" in version "rbac.authorization.k8s.io/v1beta1"
ensure CRDs are installed first
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
* Обратите внимание на конструкцию ```sed ’s/\x1b\[[0-9;]*m//g```, что по вашему она делает?

---

## Запишем конфиг в vault

```
kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
token_reviewer_jwt="$SA_JWT_TOKEN" \
kubernetes_host="$K8S_HOST" \
kubernetes_ca_cert="$SA_CA_CRT"
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

---

## создадим политку и роль в vault 

```
kubectl cp otus-policy.hcl vault-0:./

kubectl exec -it vault-0 -- vault policy write otus-policy /otus-policy.hcl

kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus  \
bound_service_account_names=vault-auth         \
bound_service_account_namespaces=default policies=otus-policy  ttl=24h
```

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




