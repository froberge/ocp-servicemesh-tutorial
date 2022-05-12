# Observabilité

Générons traffic au niveau de l'application en utilisant le scripts suivant.
```
./scripts/run.sh $GATEWAY_URL/customer
``` 

## Observabilité

:checkered_flag: Les url pour les différent dashboards requis pous la section observabitlité se trouve au niveau de `Networking -> Routes`


### Grafana & Prometheus.
Par défaut la plateforme nous donne du monitoring avec `Prometheus` et `Grafana`

#### Grafana

Plusieurs dashboard sont accessible par défaut.

Istio mesh
![mesh-grafana](images/istio-mesh-grafana.png)

Istio control plane
![mesh-grafana](images/istio-control-grafana.png)

#### Prometheus

* Il existe 2 Prometheus. Les deux permettent de scpécifier des metrics customs.

1. Celui de Openshift ou nous pouvons executer des commande de type:
    ```
    container_memory_rss{namespace="demo",container=~"customer|preference|recommendation"}
    ```


2. Celui d'Istio, ou nous pouvons avoir des métrics Istio.
    ```
    istio_requests_total{destination_service="recommendation.demo.svc.cluster.local"}
    ```

### Tracing

Avec Istio nous avons installé `Jaeger` pour le Open Tracing. Comme nos services utilise les librairing d'Open Tracing, nous pouvons les capters en utilisant `Jaeger`. Istio envoie automatiquement les données de tracage à `Jaeger`.

![jaeger-ui](images/jaeger-ui.png)


### Kiali

Kiali utilise le données qui sont fourni par Istio et OpenShift pour générer la visualisation topographique. Comme c'est un service nous avons aucun changement à faire à Istio ou OpenShift autre qu'installer l'opérateur.


__Service Graph__
![service-graph](images/kiali-1.png)

A partir de Kiali on peut avoir des informations sur:
* Les Applications
* Les Workloads
* Les Services

---
Maintenant que nous avons les outils d'observation en place, regardons comment controler le traffic à l'intérieur de la Mesh.

[Démo Contrôle du Traffic](traffic-control.md)