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
https://github.com/SergSha/lab-12.git
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
git clone https://github.com/SergSha/lab-12.git && cd ./lab-12
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
