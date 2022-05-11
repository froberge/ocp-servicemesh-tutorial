# Testing par Chaos

Le service mesh nous apport un facilit/ de faire du l'injection de chaos dans nos systemes comme des error HTTP ou des délai au niveau du network. Comprendre comment notre système réagi selon différent scénario d'erreur est un aspect important d'une architecture microservice ou tout système distribué.

---
__Erreur HTTP503__

Comme par défaut le traffic est balancé 50-50 entre v1 et v2 nous allons injecté un erruer 503 pour 50% du traffic et voir comment le system réagi.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/virtualservice-recommendation-503.yaml
    ```
* Créons le virtual service
    ```
     oc apply -f manifest/istio/virtualservice-recommendation-delay.yaml
    ```
* Générons du traffic
    ```
    ./scripts/run.sh $GATEWAY_URL/customer
    ```
    Résultat
    ```
    customer => Error: 503 - preference => Error: 503 - fault filter abort
    customer => Error: 503 - preference => Error: 503 - fault filter abort
    customer => Error: 503 - preference => Error: 503 - fault filter abort
    customer => Error: 503 - preference => Error: 503 - fault filter abort
    ```

__Clean up__
```
oc delete virtualservice recommendation -n demo
```
---
__Delai__

Un des pire chose pour un système distribué est pas nécessairement un service qui est "down" mais plus un service qui est lent a répondre, ce qui peut avoir un effet en cascade sur les opérations.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/destinationrule-recommendation.yaml
    ```
* Créons le virtual service
    ```
     oc apply -f manifest/istio/virtualservice-recommendation-delay.yaml
    ```
* Générons du traffic
    ```
    ./scripts/run.sh $GATEWAY_URL/customer
    ```
    Résultat
    ```

__CLEAN UP__
Enlevons les éléments créer pour continuer la démo.
```
./scripts/cleanup-routing.sh
```

---
Maintenant regardons le Chaos Testing

[Sécurité](security.md)
