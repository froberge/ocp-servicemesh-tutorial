# Resilience des services

---
__Retry__

Istio vient avec un politique de Retry automatiquqment. Ceci aide a rendre les services plus resilent

* Pour cette example nous allons edité  le service recommendation pour qu'il retourne un 503 100% du temps en utilisant un endoiunt qui a été codé pour nous.

    ```
    oc exec -it -n demo $(oc get pods -n demo | grep recommendation-v2 |awk '{ print $1 }'|head -1) -c recommendation /bin/bash
    ```

    ```
    curl localhost:8080/misbehave
    exit
    ```


* Mettons du traffic dans l'application et regardons se qui se passe coté Kiali
    ```
    ./scripts/run.sh $GATEWAY_URL/customer
    ```

* Réparons l'application et regardons ce qui arrive dans Kiali
    ```
    oc exec -it -n demo $(oc get pods -n demo | grep recommendation-v2 |awk '{ print $1 }'|head -1) -c recommendation /bin/bash
    ```

    ```
    curl localhost:8080/behave
    exit
    ```

---

__Timeout__

Pour cette demo nous allons introduire un delai au niveau de la version v2 du service recommendation.
```
oc patch deployment recommendation-v2 -p '{"spec":{"template":{"spec":{"containers":[{"name":"recommendation", "image":"quay.io/rhdevelopers/istio-tutorial-recommendation:v2-timeout"}]}}}}' -n demo
```

* Mettons du traffic dans l'application.
    ```
    ./scripts/run.sh $GATEWAY_URL/customer
    ```

    :WARNING: On voit ici qu'il y a un delai avant de recevoir la réponse de v2.

* Ajoutons le virtual service pour le timeout rule.
    ```
    oc apply -f manifest/istio/virtualservice-recommendation-timeout.yaml
    ```
    :WARNING: On devrait plus voir de version v2, car le service est plus lent que le timeout permis.

__CLEAN UP__
Enlevons les éléments créer pour continuer la démo.
```
oc delete virtualservice recommendation -n 
```
```
oc patch deployment recommendation-v2 -p '{"spec":{"template":{"spec":{"containers":[{"name":"recommendation", "image":"quay.io/rhdevelopers/istio-tutorial-recommendation:v2"}]}}}}' -n demo

```

---
Maintenant regardons le Chaos Testing

[Test par Chaos](docs/chaostesting.md)
