# :simple-ansible: Configuración de la infraestructura

A continuación se describen las configuraciones aplicadas a la infraestructura desplegada, automatizadas con Ansible, y la justificación de cada una de ellas.

## Imágenes contenerizadas

### Imágen sin persistencia para la VM

La imagen utilizada en el contenedor Podman dentro de la máquina virtual se basa en **MkDocs**, una librería de documentación escrita en Python. Esta herramienta permite generar sitios estáticos a partir de archivos Markdown, facilitando la creación y publicación de documentación técnica [(MkDocs, s.f.)](../referencias.md#herramientas-usadas). La imagen generada en este ejercicio contiene la documentación del propio proyecto, asegurando que el contenido se pueda visualizar de manera estructurada en un navegador.

Además, se ha utilizado el tema **Material for MkDocs**, que añade una interfaz moderna y varias opciones de personalización [(Squidfunk, s.f.)](../referencias.md#herramientas-usadas).

La documentación también está disponible a través de **GitHub Pages**, lo que permite su acceso incluso cuando la infraestructura de Azure no está desplegada. Se puede visualizar en el siguiente enlace:  

[:material-file-document: Ver documentación en GitHub Pages](https://darioreyesr25.github.io/unir-cp2)  

### Imágen con persistencia para el AKS

La imagen desplegada en el clúster de **AKS** está basada en **Azure Vote Front**, el frontend de ejemplo utilizado en las demos de Kubernetes, que se comunica con un backend Redis para almacenar el recuento de votos. Esta aplicación sirve como ejemplo de una aplicación con persistencia en Kubernetes y permite validar que los datos no se pierden al reiniciar o reprogramar el pod.

Para este ejercicio se ha utilizado la imagen pública disponible en Docker Hub: [`jsosa15/azure-vote-front:v1`](https://hub.docker.com/r/jsosa15/azure-vote-front), la cual se despliega en un contenedor dentro de Kubernetes con un volumen persistente asociado. Esto permite comprobar que la configuración de PersistentVolumeClaim y StorageClass funciona correctamente y que los datos se mantienen tras reinicios del pod.

## Configuración con Ansible 

Para la configuración y automatización del despliegue en la infraestructura se ha utilizado Ansible, organizando las tareas en roles específicos, siguiendo las buenas prácticas recomendadas en la documentación oficial de Ansible [Ansible. (s.f.-a)](../referencias.md).

La ejecución de los archivos está estructurada de la siguiente manera:

```bash
ansible
├── hosts.tmpl           # Plantilla del inventario dinámico
├── playbook.yml         # Orquesta todos los roles
├── publish_images.yml   # Publica imágenes en el ACR
├── vm_deployment.yml    # Despliega en el contenedor de la VM
├── aks_deployment.yml   # Despliega en el contenedor del AKS
├── roles
│   ├── acr              # Rol para la publicación en el ACR
│   └── vm               # Rol para la configuración de la VM
│   └── aks              # Rol para la configuración de la VM
├── secrets.yml          # Variables sensibles
└── vars.yml             # Variables generales del despliegue
```

- **ACR**: Gestiona la publicación de imágenes en **Azure Container Registry (ACR)**, construyendo y empujando imágenes desde la VM y desde la máquina local.  
- **VM**: Configura la máquina virtual, instalando **Podman**, desplegando el contenedor con **MkDocs**, gestionando autenticaciones y asegurando la persistencia con **Systemd**.  
- **AKS** *(no presente en este esquema, pero estructurable de forma similar)*: Se encargaría de desplegar aplicaciones en **Azure Kubernetes Service (AKS)**.

### Rol ACR

Para configurar el ACR se publicarán dos imágenes contenerizadas: una corresponde a un sitio estático en Nginx, que será desplegado en una máquina virtual con Podman, y la otra es una aplicación con persistencia que será ejecutada en un contenedor dentro de Azure Kubernetes Service (AKS).

!!! example ""

    Puedes ver las evidencias de este rol en el [:material-monitor-screenshot: siguiente enlace](../evidencias.md#publicacion-de-imagenes-mediante-ansible).

Este proyecto permite la publicación de las imágenes en el ACR de dos maneras:

- Publicación mediante Ansible.
- Publicación manual mediante Github Actions (fuera de alcance).

Para la publicación usando Ansible se ha generado un rol llamado `acr` que contiene todas las tareas necesarias y se estructura de la siguiente manera:

```sh
ansible/
├── roles/
│   ├── acr/                        # Rol para gestionar ACR en Ansible
│   │   ├── tasks/                  # Tareas que se ejecutan en el ACR
│   │   │   ├── main.yml            # Inclusión de todas las tareas
│   │   │   ├── install.yml         # Instala podman en la VM
│   │   │   ├── build_docs.yml      # Construcción de las imágenes
│   │   │   ├── login.yml           # Iniciar sesión en ACR
│   │   │   ├── push_mkdocs.yml     # Publicación de mkdocs en ACR
│   │   │   └── push_aks_images.yml  # Publicación de imágenes de la aplicación en ACR
│   │   └── vars/                   # Variables específicas del rol
│   │       └── main.yml            # Configuración de parámetros
```

El fichero `tasks/main.yml` dentro del rol acr, gestiona la configuración y publicación de imágenes en la máquina virtual y el Azure Container Registry (ACR).

```yaml title="main.yml"
---
- name: Install Podman on the VM
  include_tasks: install.yml

- name: Build MkDocs image
  include_tasks: build_docs.yml

- name: Login into ACR from the VM
  include_tasks: login.yml

- name: Push mkdocs image to ACR from the VM
  include_tasks: push_mkdocs.yml

- name: Push AKS application images to ACR from localhost
  include_tasks: push_aks_images.yml
```

#### Instalar Podman

Esta tarea instala Podman en la máquina virtual asegurándose de que esté disponible en el sistema. Además, actualiza la caché de paquetes antes de la instalación.

```yaml title="install.yml"
---
- name: Install Podman
  apt:
    name: podman
    state: present
    update_cache: yes
```

#### Construir imagen mkdocs

Clona el repositorio del proyecto en la máquina virtual, instala dependencias necesarias para MkDocs y WeasyPrint, construye el sitio estático de MkDocs y genera una imagen de contenedor con Podman basada en el `Dockerfile.docs`.

```yaml title="build_docs.yml"
---
- name: Ensure repository is present on the VM
  git:
    repo: "https://github.com/darioreyesr25/unir-cp2-main.git"
    dest: "/opt/unir-cp2"
    version: main

- name: Install dependencies for MkDocs
  apt:
    name:
      - python3-pip
    state: present
    update_cache: no
  become: yes

- name: Install required system dependencies for WeasyPrint
  apt:
    name:
      - libpango1.0-0
      - libpangocairo-1.0-0
      - libcairo2
    state: present
    update_cache: no
  become: yes

- name: Install project dependencies
  pip:
    requirements: "/opt/unir-cp2/requirements.txt"

- name: Build MkDocs static site
  command:
    cmd: mkdocs build
    chdir: "/opt/unir-cp2"

- name: Build Podman image on the VM
  command:
    cmd: podman build -t "{{ image_name_docs }}:{{ image_tag_docs }}" -f /opt/unir-cp2/Dockerfile.docs
    chdir: "/opt/unir-cp2"
```

#### Login en el ACR

Realiza la autenticación en Azure Container Registry (ACR) desde la máquina virtual utilizando Podman, empleando credenciales de usuario y contraseña.

```yaml title="login_acr.yml"
---
- name: Log in to ACR from the VM
  command: >
    podman login {{ acr_login_server }} 
    -u {{ acr_username }} 
    --password {{ acr_password }}
```

#### Publicar imagen `mkdocs-nginx`

Etiqueta la imagen generada de MkDocs con el formato adecuado para ACR y la sube al registro de contenedores de Azure desde la máquina virtual.

```yaml title="push_mkdocs.yml"
---
# Push MkDocs image
- name: Tag MkDocs image for ACR
  command: >
    podman tag {{ image_name_docs }}:{{ image_tag_docs }} 
    {{ acr_login_server }}/{{ image_name_docs }}:{{ image_tag_docs }}

- name: Push MkDocs image to ACR from the VM
  command: >
    podman push {{ acr_login_server }}/{{ image_name_docs }}:{{ image_tag_docs }}

```

#### Publicar imagen `azure-vote-front`

Descarga la imagen `jsosa15/azure-vote-front:v1` desde Docker Hub, la etiqueta para el ACR y finalmente la sube al registro de Azure. También se publica la imagen `redis:7.0` que se utiliza como backend.

```yaml title="push_aks_images.yml"
---
- name: Pull Azure Vote Front image from Docker Hub
  command: >
    podman pull docker.io/jsosa15/azure-vote-front:v1
  become: yes

- name: Tag Azure Vote Front image for ACR
  command: >
    podman tag docker.io/jsosa15/azure-vote-front:v1 {{ acr_name }}.azurecr.io/{{ image_name_k8s_front }}:{{ image_tag_k8s_front }}
  become: yes

- name: Push Azure Vote Front image to ACR
  command: >
    podman push {{ acr_name }}.azurecr.io/{{ image_name_k8s_front }}:{{ image_tag_k8s_front }}
  become: yes

- name: Pull Redis image from Docker Hub
  command: >
    podman pull docker.io/library/redis:7.0
  become: yes

- name: Tag Redis image for ACR
  command: >
    podman tag docker.io/library/redis:7.0 {{ acr_name }}.azurecr.io/{{ image_name_k8s_back }}:{{ image_tag_k8s_back }}
  become: yes

- name: Push Redis image to ACR
  command: >
    podman push {{ acr_name }}.azurecr.io/{{ image_name_k8s_back }}:{{ image_tag_k8s_back }}
  become: yes
```

### Rol VM

Para la publicación usando Ansible se ha generado un rol llamado `vm` que contiene todas las tareas necesarias y se estructura de la siguiente manera:

```sh
ansible/
├── roles
│   ├── vm
│   │   ├── handlers
│   │   │   └── main.yml
│   │   ├── tasks
│   │   │   ├── auth.yml
│   │   │   ├── container.yml
│   │   │   ├── main.yml
│   │   │   └── systemd.yml
│   │   └── vars
│   │       └── main.yml
```

!!! example ""

    Puedes ver las evidencias de este rol en el [:material-monitor-screenshot: siguiente enlace](../evidencias.md#despliegue-en-la-vm).

El fichero `tasks/main.yml` dentro del rol acr, gestiona la configuración y publicación de imágenes en la máquina virtual y el Azure Container Registry (ACR).

```yaml title="main.yml"
- name: Include authentication setup
  import_tasks: auth.yml

- name: Include container deployment
  import_tasks: container.yml

- name: Include systemd configuration
  import_tasks: systemd.yml
```

#### Autenticación básica

En esta tarea se configura autenticación básica en Nginx mediante `htpasswd`, asegurando que solo usuarios autorizados puedan acceder. Se instala Apache Utils, se crea el directorio de autenticación y se genera un archivo de credenciales.


```yaml
---
- name: Install Apache Utils for htpasswd
  apt:
    name: apache2-utils
    state: present
  become: yes

- name: Ensure authentication directory exists
  file:
    path: /etc/nginx/auth
    state: directory
    mode: '0755'

- name: Load secure variables
  include_vars: secrets.yml

- name: Generate htpasswd file
  command: htpasswd -bc /etc/nginx/auth/htpasswd.users darioreyesr25 "{{ site_pwd }}"
  args:
    creates: /etc/nginx/auth/htpasswd.users
```


#### Desplegar contenedor

En esta tarea se inicia sesión en el ACR para descargar la imagen del contenedor y se ejecuta con soporte SSL y autenticación básica, vinculando el archivo de credenciales generado en el paso anterior.

```yaml
---
- name: Log into Azure Container Registry (ACR)
  containers.podman.podman_login:
    registry: "{{ acr_name }}.azurecr.io"
    username: "{{ acr_username }}"
    password: "{{ acr_password }}"

- name: Run container from ACR image with SSL and Basic Auth
  containers.podman.podman_container:
    name: mkdocs_container
    image: "{{ acr_name }}.azurecr.io/{{ image_name }}:{{ image_tag }}"
    state: started
    restart_policy: always
    ports:
      - "443:443"
    volume:
      - "/etc/nginx/auth/htpasswd.users:/etc/nginx/.htpasswd:ro"
```


#### Disponibilidad como servicio

En esta tarea se convierte el contenedor en un servicio systemd, esto garantiza la disponibilidad continua del servicio sin intervención manual, ya que systemd lo monitorea y lo vuelve a iniciar si detecta que ha dejado de funcionar.

```yaml
---
- name: Generate systemd service for Podman container
  containers.podman.podman_generate_systemd:
    name: mkdocs_container
    dest: /etc/systemd/system/
    restart_policy: always

- name: Enable and start Podman container systemd service
  systemd:
    name: container-mkdocs_container
    enabled: yes
    state: started
    daemon_reload: yes
```

### Rol AKS

Para el despliegue de la aplicación en el clúster de Kubernetes mediante Ansible se ha generado un rol llamado `aks`, que contiene todas las tareas necesarias y se estructura de la siguiente manera:

```sh
ansible/
├── roles
│   ├── aks
│   │   ├── tasks
│   │   │   ├── acr_auth.yml
│   │   │   ├── deploy.yml
│   │   │   ├── main.yml
│   │   │   ├── namespace.yml
│   │   │   ├── pvc.yml
│   │   │   └── service.yml
│   │   ├── templates
│   │   │   ├── acr-auth.json.j2
│   │   │   ├── deployment.yml.j2
│   │   │   ├── pvc.yml.j2
│   │   │   └── service.yml.j2
│   │   └── vars
│   │       └── main.yml
```

!!! example ""

    Puedes ver las evidencias de este rol en el [:material-monitor-screenshot: siguiente enlace](../evidencias.md#despliegue-en-el-aks).

El fichero `tasks/main.yml` dentro del rol `aks` orquesta todas las tareas necesarias para desplegar la aplicación, incluyendo la creación del namespace, los volúmenes persistentes, el despliegue de los contenedores y el servicio de acceso.

```yaml title="main.yml"
- name: Create Kubernetes Namespace
  import_tasks: namespace.yml

- name: Create ACR Secret in Kubernetes
  import_tasks: acr_auth.yml

- name: Apply PersistentVolumeClaim
  import_tasks: pvc.yml

- name: Deploy Application
  import_tasks: deploy.yml

- name: Create LoadBalancer Service
  import_tasks: service.yml
```

#### Crear Namespace

Esta tarea se encarga de crear el namespace donde se desplegarán todos los recursos de la aplicación dentro del clúster de AKS, asegurando su aislamiento lógico del resto de workloads.

{% raw %}
```yaml title="namespace.yml"
---
- name: Create Kubernetes Namespace
  kubernetes.core.k8s:
    name: "{{ namespace }}"
    api_version: v1
    kind: Namespace
    state: present
```
{% endraw %}

#### Crear secreto en el ACR

Esta tarea crea un `Secret` en el clúster de AKS con las credenciales necesarias para acceder al Azure Container Registry (ACR), permitiendo que Kubernetes pueda descargar imágenes privadas.

{% raw %}
```yaml title="acr_auth.yml"
- name: Create ACR Secret in Kubernetes
  kubernetes.core.k8s:
    state: present
    namespace: "{{ namespace }}"
    definition:
      apiVersion: v1
      kind: Secret
      metadata:
        name: acr-secret
      type: kubernetes.io/dockerconfigjson
      data:
        .dockerconfigjson: "&#123;&#123; lookup('template', 'acr-auth.json.j2') &#124; from_yaml &#124; to_json &#124; b64encode &#125;&#125;"
```
{% endraw %}

El secreto se genera a partir de la plantilla `acr-auth.json.j2`, que contiene las credenciales codificadas en base64:

{% raw %}
```json title="acr-auth.json.j2"
{
  "auths": {
    "{{ acr_name }}.azurecr.io": {
      "username": "{{ acr_username }}",
      "password": "{{ acr_password }}",
      "auth": "&#123;&#123; (acr_username + ':' + acr_password) &#124; b64encode &#125;&#125;"
    }
  }
}
```
{% endraw %}

#### Crear volumen persistente

Esta tarea crea un `PersistentVolumeClaim` en el clúster de AKS, necesario para mantener los datos persistentes entre reinicios del contenedor.

{% raw %}
```yaml title="pvc.yml"
- name: Apply PersistentVolumeClaim
  kubernetes.core.k8s:
    state: present
    namespace: "{{ namespace }}"
    definition: "{{ lookup('template', 'pvc.yml.j2') }}"
```
{% endraw %}

La plantilla utilizada define un volumen de 5GiB con acceso en modo lectura-escritura por un único nodo:

{% raw %}
```yaml title="pvc.yml.j2"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ pvc_name }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```
{% endraw %}

#### Desplegar aplicación

Esta tarea aplica el `Deployment` de Kubernetes necesario para ejecutar el frontend (`azure-vote-front`) y el backend (`redis`) en el clúster. El manifiesto utiliza las imágenes publicadas en el ACR y configura el `imagePullSecret` para poder acceder al registro privado.

{% raw %}
```yaml title="deploy.yml"
- name: Deploy Application
  kubernetes.core.k8s:
    state: present
    namespace: "{{ namespace }}"
    definition: "{{ lookup('template', 'deployment.yml.j2') }}"
```
{% endraw %}

La plantilla del manifiesto define dos `Deployment` (frontend y backend) y utiliza un `PersistentVolumeClaim` para el backend Redis.

{% raw %}
```yaml title="deployment.yml.j2"
---
# Backend (Redis)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ back_deployment_name }}
  namespace: {{ k8s_namespace }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ back_deployment_name }}
  template:
    metadata:
      labels:
        app: {{ back_deployment_name }}
    spec:
      containers:
      - name: {{ back_deployment_name }}
        image: "{{ acr_name }}.azurecr.io/{{ image_name_k8s_back }}:{{ image_tag_k8s_back }}"
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: data
          mountPath: "/data"
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: {{ pvc_name }}
      imagePullSecrets:
      - name: acr-secret

---
# Frontend (Azure Vote)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ front_deployment_name }}
  namespace: {{ k8s_namespace }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ front_deployment_name }}
  template:
    metadata:
      labels:
        app: {{ front_deployment_name }}
    spec:
      containers:
      - name: {{ front_deployment_name }}
        image: "{{ acr_name }}.azurecr.io/{{ image_name_k8s_front }}:{{ image_tag_k8s_front }}"
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "{{ back_service_name }}"
      imagePullSecrets:
      - name: acr-secret
```
{% endraw %}
