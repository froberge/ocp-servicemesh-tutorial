# Controle du traffic

Quelque terme a savoir avant de commencer.
* `Gateway:` Le load balancer qui est au edge de la Mesh et qui accepte le traffic qui entre/sort soit en TCP ou HTTP connections.
* `Virtual Services`: Sert a diriger le traffic dans la mesh a partir du gateway vers les applications, ou d'un service vers un autre service en applicant les politiques
* `Destination Rules:` Représente les régles a appliquer sur le trafic, comme les TLS setting ou le circuit braking.


## Règles simple de traffic.

Pour nous aider avec cette section nous allons déployer une deuxième version du service recommendation.

```
oc apply -f manifest/kubernetes/recommendation/deployment-v2.yaml -n demo
```

![control-traffic-1](images/control-traffic-1.png)

:WARNING: Par défault, OpenShift utilise le principle round-robin pour la distribution de la charge, donc on devrait voir v1, v2 environs 50% du temps.

![control-traffic-2](images/control-traffic-2.png)

---
__OPTIONEL__ Si on scale la v2 a 2 replicas, on devrait voir 1 v1 pour 2 v2.

```
oc scale --replicas=2 deployment/recommendation-v2 -n demo
```

une fois les test effectué, remettre v2 a seulement 1 replicas

```
oc scale --replicas=1 deployment/recommendation-v2 -n demo
```
---

## Changer les régles avec Istio

* Faisson en premier un règles de destination.
    ```
    oc apply -f manifest/istio/destinationrule-recommendation_v1_v2.yaml
    ```

__Envoyer tout le traffic vers v2__

* Créons le Virtual Service qui envoi tout le traffic vers v2.
    ```
    oc apply -f manifest/istio/virtualservice-recommendation_v2.yaml
    ```
* Générons du traffic
    ```
    ./scripts/run.sh $GATEWAY_URL/customer
    ```
    _On devrait seulement voir v2_

__Envoyer tout le traffic vers v1__

* Créons le Virtual Service qui envoi tout le traffic vers v1.
    ```
     oc replace -f manifest/istio/virtualservice-recommendation_v1.yaml
    ```
    _On devrait maintenant voir seulement voir v1_

__Retour a v1 et v2__
* Deletons le Virtual Service
    ```
    oc delete virtualservice recommendation -n demo
    ```
    _On devrait maintenant voir  v1 et v2_

__Déploiement Canary - Partager le traffic entre v1 et v2__

* Créer un Virtual Service qui envoi 80% du traffic a v1 et 20% a v2
    ```
    ooc apply -f manifest/istio/virtualservice-recommendation_v1_v2.yaml.yaml -n demo
    ```
    _On devrait maintenant voir  v1 et v2 dans une proportion 80-20_

:WARNING: on peut jouer avec le pourcentage et voir ce qui arrive en editant le fichier.

__CLEAN UP__
Enlevons les éléments créer pour continuer la démo.
```
./scripts/cleanup-routing.sh
```

---

## Régles de traffic plus avancé.

__Routing intelligent basé sur le user-agent header__

:star: Le header "user-agent" est ajouté au OpenTracing baggage dans le service Customer. Il est par la suite propagé automatiquement à tout les downstream services.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/destinationrule-recommendation_v1_v2.yaml
    ```
* Créons le virtual service
    ```
     oc apply -f manifest/istio/virtualservice-recommendation-browser.yaml
    ```

* Faire un appel en utilisant le user-agent
    ```
    curl -A Safari $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => preference => recommendation v2 from .....
    ```

    ```
    curl -A Firefox $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => preference => recommendation v1 from .....
    ```

__CLEAN UP__
Enlevons les éléments créer pour continuer la démo.
```
./scripts/cleanup-routing.sh
```

---

__Mirroring__

Le `mirroring` du traffic, aussi appelé `shadowing` est un concept puissant dans istio. IL permet au d'apporter des nouvelles fonctionnalitées en production en limitant les risques. En effet le `mirroring` consiste a envoyer un copy du traffic live à un service sélectionné, sans impater le services primaire.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/destinationrule-recommendation_v1_v2.yaml
    ```

* Créons le virtual service
    ```
     oc apply -f manifest/istio/virtualservice-recommendation-mirror_v1_v2.yaml
    ```
* Faire un appel
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => preference => recommendation v1 from .....
    ```

* Regardons les logs de v2: Un ligne devrait s'ajouté dans le logs.
    ```
    oc logs -f `oc get pods -n demo |grep recommendation-v2|awk '{ print $1 }'` -c recommendation -n demo
    ```

__CLEAN UP__
Enlevons les éléments créer pour continuer la démo.
```
./scripts/cleanup-routing.sh
```


__Load Balancer__

Commen mentionné au paravent, OpenShift utilise la politique de Round Robin par défaut. Avec les Service Mesh nous pouvons facilement le changer. Il suivi d'introduire la bonne destination rule.

```
oc apply -f manifest/istio/destinationrule-recommendation-lb_random.yaml
```

:clipboard: En scalant la version v2 a 2 replicas on voit encore mieux le random.

__CLEAN UP__
Enlevons les éléments créer pour continuer la démo.
```
./scripts/cleanup-routing.sh
```

---
Maintenant regardons la résilience des service.

[Démo Résilience des services](resiliency.md)