# Introduction à Red Hat OpenShift Service Mesh

Bienvenue dans l'atelier de travail sur [**Red Hat OpenShift Service Mesh**](https://www.redhat.com/en/technologies/cloud-computing/openshift/what-is-openshift-service-mesh#:~:text=Red%20Hat%C2%AE%20OpenShift%C2%AE,microservices%20in%20your%20service%20mesh.)

---
## Table des matières
 * [Installation du ServiceMesh](https://github.com/froberge/howto-ocp-servicemesh-setup/)
 * [Turotial](#déploiement-des-microservices)
 

## Tutorial

Pour ce tutorial nous utilisons 3 microservices simple qui on été développé par le [Red Hat developer group](https://developers.redhat.com/).

```
    +----------------+       +----------------+      +----------------+
    |    Customer    |  ---> |   Preference   | ---> | Recommendation |
    +----------------+       +----------------+      +----------------+
```


### Contenu
* [Déploiement des service](docs/service-deployment.md)
* [Démo Observabilité](docs/observability.md)
* [Démo Contrôle du Traffic](docs/traffic-control.md)
* [Démo Résilience des services](docs/resiliency.md)
* [Test par Chaos](docs/chaostesting.md)
* [Sécurité](docs/security.md)