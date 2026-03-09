# 🚀 Unir Caso Práctico 2

Este repositorio contiene la solución del **Caso Práctico 2**, en el cual se ha desplegado una infraestructura en **Microsoft Azure** de forma automatizada utilizando **Terraform** y **Ansible**. Se incluyen configuraciones para la creación de recursos en la nube, instalación de servicios y despliegue de aplicaciones en contenedores con almacenamiento persistente.

## 🎯 Objetivos

- Crear infraestructura en **Azure** de forma automatizada.
- Gestionar la configuración con **Ansible**.
- Desplegar aplicaciones en contenedores sobre **Linux y AKS**.
- Implementar almacenamiento persistente en **Kubernetes**.

## 🗂️ Estructura del repositorio

El proyecto se organiza en tres grandes bloques: infraestructura, despliegue y documentación. A continuación se resume su estructura principal:

```
📦 repo-root
├── terraform/        # Código para el despliegue de la infraestructura (ACR, VM, AKS)
├── ansible/          # Playbooks y roles para configurar la VM y desplegar en AKS
├── docs/             # Documentación del proyecto (MkDocs)
├── site/             # Sitio estático generado de la documentación
├── setup.sh          # Script para exportar variables tras despliegue
├── mkdocs.yml        # Configuración de MkDocs
├── Dockerfile.docs   # Dockerfile para generar la imagen de documentación
├── requirements.txt  # Dependencias de Python
├── README.md         # Descripción general del proyecto
└── LICENSE           # Licencia del repositorio
```

## ⚙️ Tecnologías utilizadas

- **Terraform**: Creación de infraestructura en Azure (ACR, VM, AKS).
- **Ansible**: Configuración automática de servicios y despliegue de aplicaciones.
- **Podman**: Contenedorización de aplicaciones en la VM.
- **Kubernetes (AKS)**: Orquestación de aplicaciones con almacenamiento persistente.

---

📌 **Autor**: *[@darioreyesr25](https://github.com/darioreyesr25)*  
📌 **Fecha**: *23-03-2025*
