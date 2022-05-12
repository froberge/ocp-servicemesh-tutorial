# Sécurité

---
__Egress__

* Le ServiceMesh controle comment les services peuvent-être accédé de l'extérieur (Ingress) ainsi que comment les services peuvent accéder des API externe (egress). 

* Pour pouvoir accéder on doit appliqué un règles qui nous permets d'accéder l'extérieur.

* Pour cette example nous allons déployé une 3ieme version du service recommendation et envoyé tout le traffic vers v3.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/destinationrule-recommendation_v1_v2_v3.yaml
    ```
* Créons le virtual service
    ```
     oc apply -f manifest/istio/virtualservice-recommendation-browser.yaml
    ```

* Faire un appel
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => Error: 503 - preference => Error: 500 - <!doctype html> ....
    ```

* Ajoutons maintenant un service entry pour permettre au service d'accéder l'extérieur.

    ```
    oc apply -f manifest/istio/serviceentry-worldclockapi-egress.yaml
    ```

    Résultat
    ```
    customer => preference => recommendation v3 2022-05-11T16:58+02:00 from 'recommendation-v3-5c858b8c9d-vlnth': 10
    ```

:construction: __CLEAN UP__
```
oc delete serviceentry worldclockapi-egress-rule -n demo
```
```
./scripts/cleanup-routing.sh
```
```
oc delete all -n demo -l app=recommendation,version=v3
```
---

__Politique Authorization__


Istio nous permet de définir qui a accèes a quoi, faisons une example qui défini le path d'authorization `customer->preference->recommendation`.

* Commençons par bloquer tout le traffic qui arrivent dans l'application
    ```
    oc apply -f manifest/istio/policies/authorizationpolicy-deny-all.yaml -n demo
    ```
* Faire un appel
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    RBAC: access denied
    ```

* `ALLOW Customer`

    ```
    oc apply -f manifest/istio/policies/authorizationpolicy-allow-customer.yaml -n demo
    ```

    Call
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => Error: 403 - RBAC: access denied
    ```

* `ALLOW Preference`

    ```
    oc apply -f manifest/istio/policies/authorizationpolicy-allow-preference.yaml -n demo
    ```

    Call
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => Error: 503 - preference => Error: 403 - RBAC: access denied
    ```

* `ALLOW recommendation`

    ```
    oc apply -f manifest/istio/policies/authorizationpolicy-allow-recommendation.yaml -n demo
    ```

    Call
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => preference => recommendation v1 from 'recommendation-v1-dd8544f7c-rv6cf': 1
    ```

`Validé un autre path qui est pas permisÈ

* À partir de recommendation allons vers préférence.
    ```
    oc exec -it -n demo $(oc get pods -n demo | grep recommendation-v2 |awk '{ print $1 }'|head -1) -c recommendation /bin/bash
    ```

    ```
    curl preference:8080
    ```
    
    Résultat
    ```
    RBAC: access denied
    ```
    ```
    exit
    ```

:construction: __CLEAN UP__
```
./scripts/cleanup-security-policy.sh
```
---

__Authentication JWT__

Pouvoir permettent seulement au usagé qui on une authentication valide de connecter a notre application est un scénation courant au niveau des systèmes distribué.

* Définissons un requête d'authentification
    ```
    oc apply -f manifest/istio/enduser-authentication-jwt.yaml -n demo
    ```

* Faire un appel
    ```
    curl $GATEWAY_URL/customer -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkRIRmJwb0lVcXJZOHQyenBBMnFYZkNtcjVWTzVaRXI0UnpIVV8tZW52dlEiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ2ODU5ODk3MDAsImZvbyI6ImJhciIsImlhdCI6MTUzMjM4OTcwMCwiaXNzIjoidGVzdGluZ0BzZWN1cmUuaXN0aW8uaW8iLCJzdWIiOiJ0ZXN0aW5nQHNlY3VyZS5pc3Rpby5pbyJ9.CfNnxWP2tcnR9q0vxyxweaF3ovQYHYZl82hAUsn21bwQd9zP7c-LS9qd_vpdLG4Tn1A15NxfCjp5f7QNBUo-KC9PJqYpgGbaXhaGx7bEdFWjcwv3nZzvc7M__ZpaCERdwU7igUmJqYGBYQ51vr2njU9ZimyKkfDe3axcyiBZde7G6dabliUosJvvKOPcKIWPccCgefSj_GNfwIip3-SsFdlR7BtbVUcqR-yv-XOxJ3Uc1MI0tz3uMiiZcyPV7sNCU4KRnemRIMHVOfuvHsU60_GhGbiSFzgPTAa9WTltbnarTbxudb_YEOx12JiwYToeX0DCPb43W1tzIBxgm8NxUU"
    ```

    Résultat
    ```
    Jwt verification fails
    ```
:WARNING: La connection n'est pas possible car ce n'est pas une token valide.

* Faire un appel avec un Token valide
    ```
    token=$(curl https://gist.githubusercontent.com/lordofthejars/a02485d70c99eba70980e0a92b2c97ed/raw/f16b938464b01a2e721567217f672f11dc4ef565/token.simple.jwt -s)
    ```
    ```
    echo $token
    ``` 

    ```
    curl -H "Authorization: Bearer $token" $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => preference => recommendation v2 from '6c468ccf49-9wmv5': 3
    ```

:construction: __CLEAN UP__

```
oc delete  requestauthentication customerjwt -n demo
```
---

