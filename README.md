# lab-13
otus | hashicorp vault

### Домашнее задание
веб портал с централизованным хранилищем секретов в nomad

#### Цель:
развернуть кластер веб приложения через nomad;
там же развернуть vault кластер и реализовать обновления паролей к БД через каждые 2 минуты.

https://github.com/erlong15/otus-vault/blob/main/k8s-materials/04-Vault/00-Homework.md

#### Критерии оценки:
Статус "Принято" ставится при выполнении перечисленных требований.


### Выполнение домашнего задания

Стенд будем разворачивать с помощью Terraform на YandexCloud, настройку серверов будем выполнять с помощью Kubernetes.

Необходимые файлы размещены в репозитории GitHub по ссылке:
```
https://github.com/SergSha/lab-13.git
```

Для начала получаем OAUTH токен:
```
https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
```

Настраиваем аутентификации в консоли:
```
export YC_TOKEN=$(yc iam create-token)
export TF_VAR_yc_token=$YC_TOKEN
```

Скачиваем проект с гитхаба:
```
git clone https://github.com/SergSha/lab-13.git && cd ./lab-13
```

В файле input.auto.tfvars нужно вставить свой 'cloud_id':
```
cloud_id  = "..."
```

Kubernetes кластер будем разворачивать с помощью Terraform, а все установки и настройки необходимых приложений будем реализовывать с помощью команд kubectl и helm.

Установка kubectl с помощью встроенного пакетного менеджера:
```
# This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF
sudo dnf install -y kubectl
```

Установка helm:
```
curl -LO https://get.helm.sh/helm-v3.13.3-linux-amd64.tar.gz
tar -xf ./helm-v3.13.3-linux-amd64.tar.gz
sudo mv ./linux-amd64/helm /usr/local/bin/
rm -rf ./helm-v3.13.3-linux-amd64.tar.gz ./linux-amd64/
```

Для того чтобы развернуть kubernetes кластер, нужно выполнить следующую команду:
```
terraform init && terraform apply -auto-approve
```

В качестве балансировщика будем использовать Contour Ingress (https://projectcontour.io/):
```
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```

Установим mysql:
```
helm upgrade --install mysql ./Charts/mysql/ -f ./Charts/values.yaml
```

Установим wordpress:
```
helm upgrade --install wordpress ./Charts/wordpress/ -f ./Charts/values.yaml
```

С помощью следующей команды:
```
kubectl describe ingress wordpress-ingress
```

получим публичный IP для доступа к веб-странице WordPress:
```
[user@rocky9 lab-12]$ kubectl describe ingress wordpress-ingress
Name:             wordpress-ingress
Labels:           app=wordpress
                  app.kubernetes.io/managed-by=Helm
Namespace:        default
Address:          158.160.133.132      # <--- Public IP address
Ingress Class:    contour
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /   wordpress-svc:80 (10.112.128.10:80,10.112.129.7:80)
Annotations:  meta.helm.sh/release-name: wordpress
              meta.helm.sh/release-namespace: default
Events:       <none>
[user@rocky9 lab-12]$ 
```

Полученный IP адрес вводим в адресной строке браузера, получим стартовую веб-страницу Wordpress:

<img src="pics/screen-001.png" alt="screen-001.png" />

Можно сделать вывод, что развёрнутый kubernetes кластер работает должным образом.















helm install consul ./consul-helm/
helm install vault ./vault-helm/

kubectl exec -it vault-0 -- vault operator init --key-shares=5 --key-threshold=3
---
Unseal Key 1: SxGjcXeqDXFMXC3bYUvuymBbtjs5tq9C0xw9bDvNpfJ/
Unseal Key 2: j0w47uZIYODhdm3UZjnIF8XCo+C6t7mEEf8ZE/pnTYB4
Unseal Key 3: eQy6Phhn4LEXq2KEQC5aUmGxz+gPX+6We5mOojmj6lqD
Unseal Key 4: Vnx3s9/hU4xT41OodFb0/3vTqEDiNwVBQmWjLX39Svq+
Unseal Key 5: BUD1uKP3LJKFRvswlkqLEOU0BsQRrNsRV3Rls01sfiwS

Initial Root Token: hvs.61gFjOcaoapfyBmHXCFrj4vm
---

kubectl exec -it vault-0 -- vault operator unseal 'SxGjcXeqDXFMXC3bYUvuymBbtjs5tq9C0xw9bDvNpfJ/'
kubectl exec -it vault-1 -- vault operator unseal 'SxGjcXeqDXFMXC3bYUvuymBbtjs5tq9C0xw9bDvNpfJ/'
kubectl exec -it vault-2 -- vault operator unseal 'SxGjcXeqDXFMXC3bYUvuymBbtjs5tq9C0xw9bDvNpfJ/'
kubectl exec -it vault-0 -- vault operator unseal 'j0w47uZIYODhdm3UZjnIF8XCo+C6t7mEEf8ZE/pnTYB4'
kubectl exec -it vault-1 -- vault operator unseal 'j0w47uZIYODhdm3UZjnIF8XCo+C6t7mEEf8ZE/pnTYB4'
kubectl exec -it vault-2 -- vault operator unseal 'j0w47uZIYODhdm3UZjnIF8XCo+C6t7mEEf8ZE/pnTYB4'
kubectl exec -it vault-0 -- vault operator unseal 'eQy6Phhn4LEXq2KEQC5aUmGxz+gPX+6We5mOojmj6lqD'
kubectl exec -it vault-1 -- vault operator unseal 'eQy6Phhn4LEXq2KEQC5aUmGxz+gPX+6We5mOojmj6lqD'
kubectl exec -it vault-2 -- vault operator unseal 'eQy6Phhn4LEXq2KEQC5aUmGxz+gPX+6We5mOojmj6lqD'

kubectl exec -it vault-0 -- vault login
kubectl exec -it vault-0 -- vault auth list

kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
kubectl exec -it vault-0 -- vault secrets list --detailed
kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='h7sgm4j9ztp'
kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='h7sgm4j9ztp'
kubectl exec -it vault-0 -- vault read otus/otus-ro/config
kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config

kubectl exec -it vault-0 -- vault auth enable kubernetes
kubectl exec -it vault-0 -- vault auth list

kubectl create serviceaccount vault-auth
kubectl apply -f ./vault-auth-service-account.yml

export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')
export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g' )

kubectl exec -it vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$K8S_HOST" kubernetes_ca_cert="$SA_CA_CRT"
kubectl cp otus-policy.hcl vault-0:/tmp/
kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=otus-policy  ttl=24h

cd ./vault-guides/identity/vault-agent-k8s-demo
kubectl create -f ./configmap.yaml
kubectl get configmap example-vault-agent-config -o yaml
kubectl apply -f example-k8s-spec.yaml --record

kubectl get pods

kubectl describe pods vault-agent-example

kubectl logs vault-agent-example

kubectl get cm

kubectl describe cm example-vault-agent-config

cd ~/otus/lab-13/
terraform destroy -auto-approve

git status
git add .
git commit -m 'edit 00-Homework.md, configmap.yaml'
git push -u origin main
git status














helm install consul ./consul-helm/
helm install vault ./vault-helm/

kubectl exec -it vault-0 -- vault operator init --key-shares=5 --key-threshold=3
---
Unseal Key 1: hSUclB2HR1F471aGDEQ6ApXYBmr6Llcq4bXLDvvUj+Zv
Unseal Key 2: o7LBS/v3shu1nelrSTLTNDXLun8BOSHY61FHyGZBb7aN
Unseal Key 3: fWNj4Mrd8jO6oQsySfrCEE2j2sU9apPk1xpRuXD/akTI
Unseal Key 4: kgxXh91NxWL1gtagwOTGrdP/hJvkYLzSZJ60YqNc5Frm
Unseal Key 5: odkypq22mJRawJhrET6HD42sJJ0CsTxnQ6KY2TSm0St1

Initial Root Token: hvs.k9pmLkPsDRgqD4nd8MTFpNtk
---

kubectl exec -it vault-0 -- vault operator unseal 'hSUclB2HR1F471aGDEQ6ApXYBmr6Llcq4bXLDvvUj+Zv'
kubectl exec -it vault-1 -- vault operator unseal 'hSUclB2HR1F471aGDEQ6ApXYBmr6Llcq4bXLDvvUj+Zv'
kubectl exec -it vault-2 -- vault operator unseal 'hSUclB2HR1F471aGDEQ6ApXYBmr6Llcq4bXLDvvUj+Zv'
kubectl exec -it vault-0 -- vault operator unseal 'o7LBS/v3shu1nelrSTLTNDXLun8BOSHY61FHyGZBb7aN'
kubectl exec -it vault-1 -- vault operator unseal 'o7LBS/v3shu1nelrSTLTNDXLun8BOSHY61FHyGZBb7aN'
kubectl exec -it vault-2 -- vault operator unseal 'o7LBS/v3shu1nelrSTLTNDXLun8BOSHY61FHyGZBb7aN'
kubectl exec -it vault-0 -- vault operator unseal 'fWNj4Mrd8jO6oQsySfrCEE2j2sU9apPk1xpRuXD/akTI'
kubectl exec -it vault-1 -- vault operator unseal 'fWNj4Mrd8jO6oQsySfrCEE2j2sU9apPk1xpRuXD/akTI'
kubectl exec -it vault-2 -- vault operator unseal 'fWNj4Mrd8jO6oQsySfrCEE2j2sU9apPk1xpRuXD/akTI'

kubectl exec -it vault-0 -- vault login
kubectl exec -it vault-0 -- vault auth list

kubectl exec -it vault-0 -- vault secrets enable --path=otus kv
kubectl exec -it vault-0 -- vault secrets list --detailed
kubectl exec -it vault-0 -- vault kv put otus/otus-ro/config username='otus' password='h7sgm4j9ztp'
kubectl exec -it vault-0 -- vault kv put otus/otus-rw/config username='otus' password='h7sgm4j9ztp'
kubectl exec -it vault-0 -- vault read otus/otus-ro/config
kubectl exec -it vault-0 -- vault kv get otus/otus-rw/config

kubectl exec -it vault-0 -- vault auth enable kubernetes
kubectl exec -it vault-0 -- vault auth list

kubectl apply -f ./vault-auth-service-account.yml

kubectl apply --filename vault-auth-secret.yaml

export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
- alternative: export VAULT_SA_NAME=$(kubectl get secrets --output=json \
    | jq -r '.items[].metadata | select(.name|startswith("vault-auth-")).name')

export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
export K8S_HOST=$(more ~/.kube/config | grep server |awk '/http/ {print $NF}')
export K8S_HOST=$(kubectl cluster-info | grep 'Kubernetes control plane' | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g' )

kubectl exec -it vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$K8S_HOST" kubernetes_ca_cert="$SA_CA_CRT"
kubectl cp otus-policy.hcl vault-0:/tmp/
kubectl exec -it vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
kubectl exec -it vault-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth bound_service_account_namespaces=default policies=otus-policy  ttl=24h

cd ./vault-guides/identity/vault-agent-k8s-demo
kubectl create -f ./configmap.yaml
kubectl get configmap example-vault-agent-config -o yaml
kubectl apply -f example-k8s-spec.yaml --record

kubectl get pods

kubectl describe pods vault-agent-example

kubectl logs vault-agent-example

kubectl get cm

kubectl describe cm example-vault-agent-config

cd ~/otus/lab-13/
terraform destroy -auto-approve

git status
git add .
git commit -m 'edit 00-Homework.md, configmap.yaml'
git push -u origin main
git status
