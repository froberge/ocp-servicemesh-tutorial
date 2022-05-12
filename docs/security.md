# Sécurité

---

Le ServiceMesh controle comment les services peuvent-être accédé de l'extérieur (Ingress) ainsi que comment les services peuvent accéder des API externe (egress). 

__Egress__
* Pour pouvoir accéder à l'extérieur de la mesh, on applique une règle d'accès.

* Déployons une 3ieme version de recommendation qui accède un service à l'extérieur de la Mesh.

* Créons la destination rule
    ```
    oc apply -f manifest/istio/destinationrule-recommendation_v1_v2_v3.yaml
    ```
* Créons le virtual service pour envoyé 100% du traffic vers v3.
    ```
    oc apply -f manifest/istio/virtualservice-recommendation_v3.yaml
    ```

* Test
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => Error: 503 - preference => Error: 500 - <!doctype html> ....
    ```

* Ajoutons un service entry pour permettre au service d'accéder l'extérieur.

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
* Test
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

    Test
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

    Test
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

    Test
    ```
    curl $GATEWAY_URL/customer
    ```

    Résultat
    ```
    customer => preference => recommendation v1 from 'recommendation-v1-dd8544f7c-rv6cf': 1
    ```

* `Validation d'un autre path qui n'est pas permis`

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

Pouvoir permettent seulement le traffic qui a une token authentication valide de se connecter à notre application est un scénario courant au niveau des applicaiton microservice.

* Définissons une requête d'authentification
    ```
    oc apply -f manifest/istio/enduser-authentication-jwt.yaml -n demo
    ```

* Test
    ```
    curl $GATEWAY_URL/customer -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkRIRmJwb0lVcXJZOHQyenBBMnFYZkNtcjVWTzVaRXI0UnpIVV8tZW52dlEiLCJ0eXAiOiJKV1QifQ.eyJleHAiOjQ2ODU5ODk3MDAsImZvbyI6ImJhciIsImlhdCI6MTUzMjM4OTcwMCwiaXNzIjoidGVzdGluZ0BzZWN1cmUuaXN0aW8uaW8iLCJzdWIiOiJ0ZXN0aW5nQHNlY3VyZS5pc3Rpby5pbyJ9.CfNnxWP2tcnR9q0vxyxweaF3ovQYHYZl82hAUsn21bwQd9zP7c-LS9qd_vpdLG4Tn1A15NxfCjp5f7QNBUo-KC9PJqYpgGbaXhaGx7bEdFWjcwv3nZzvc7M__ZpaCERdwU7igUmJqYGBYQ51vr2njU9ZimyKkfDe3axcyiBZde7G6dabliUosJvvKOPcKIWPccCgefSj_GNfwIip3-SsFdlR7BtbVUcqR-yv-XOxJ3Uc1MI0tz3uMiiZcyPV7sNCU4KRnemRIMHVOfuvHsU60_GhGbiSFzgPTAa9WTltbnarTbxudb_YEOx12JiwYToeX0DCPb43W1tzIBxgm8NxUU"
    ```

    Résultat
    ```
    Jwt verification fails
    ```
:warning: La connection n'est pas possible car ce n'est pas une token valide.

* Test avec un token valide
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

