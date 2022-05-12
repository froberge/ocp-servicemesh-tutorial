# Testing par Chaos

Avec le service mesh nous pouvons faire de l'injection de chaos dans nos systèmes comme des erreurs HTTP ou des délais au niveau du network. Comprendre comment le système réagi selon différent scénarios est un aspect important d'une architecture microservice.

---
__Erreur HTTP503__

Comme par défaut le traffic est balancé 50-50 entre v1 et v2 nous allons injecté un erreur 503 pour 50% du traffic et voir comment le system réagi.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/destinationrule-recommendation_v1_v2.yaml
    ```
* Créons le virtual service
    ```
     oc apply -f manifest/istio/virtualservice-recommendation-503.yaml
    ```
* Test
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

:construction: __CLEAN UP__
```
oc delete virtualservice recommendation -n demo
```
---
__Delai__

Une des pire chose pour une architecture microservice n'est pas nécessairement un service qui est "down" mais plus un service qui est lent à répondre, ce qui peut avoir un effet en cascade sur les opérations.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/destinationrule-recommendation.yaml
    ```
* Créons le virtual service
    ```
     oc apply -f manifest/istio/virtualservice-recommendation-delay.yaml
    ```
* Test
    ```
    ./scripts/run.sh $GATEWAY_URL/customer
    ```

:construction: __CLEAN UP__
```
./scripts/cleanup-routing.sh
```

---
Maintenant regardons la sécurité

[Sécurité](security.md)
