# Déploiement des Services

Pour commencez nous devons mettre en place le project dans OpenShift sous lequel nous allons:
* Faire les déploiement.
* Mettre en place Istio

Les service utilisé viendrons d'images déjà fabriqué qui se trouve [Quay.io](quay.io/rhdevelopers).
* [Customer](https://quay.io/rhdevelopers/istio-tutorial-customer)
* [Preference](https://quay.io/rhdevelopers/istio-tutorial-preference)
* [Recommendation](https://quay.io/rhdevelopers/istio-tutorial-recommendation)


## Mise en place du projet.
1. Créer un project avec les infirmations suivantes.
    * `Nom:` demo
    * `Display:` Project pour demo ServiceMesh

    Image de la création du project à partir de l'interface Web.
    ![create-project](images/createproject.png)


2. Ajoutez le nouveau project au service mesh. Pour ce faire nous allons modifier le Member Roll.

* À partir du UI nous devons aller dans __Intaslled Operator__
* Dans le project _istio-system_, selectionner l'operator __Red Hat OpenShift Service Mesh__
* Allez dans l'onglet __Istio Servicw Mesh Member Roll__
* Selectionnez __SMMR default__
* En haut a droite, sélectionnez __Edit Service MeshMemberRoll__. Ceci vous ouvre le yaml
* Dans la section __members__ sous spec, ajouté le nom du projet __demo__ .
Le yaml devrait ressemblez a celui-ci.
    ```
    ...
    spec:
    members:
        - demo
    status:
    ...
    ```

* Faire __Save__.
___

## Déploiement de Customer

* Déploiement de l'application
    ```
    oc create -f manifest/kubernetes/customer/deployment.yaml -n demo
    ```
* Création du service
    ``` 
    oc create -f manifest/kubernetes/customer/service.yaml -n demo
    ```
* Nous devons exposer le service customer, pour permettre a l'utilisateur d'intéragir avec. Nous allons donc créer le Gateway
    ``` 
    oc create -f manifest/kubernetes/customer/gateway.yaml -n demo
    ```

* Récupérons URL du gateway dans un variable
    ``` 
    export GATEWAY_URL=$(kubectl get route istio-ingressgateway -n istio-system -o=jsonpath="{.spec.host}")
    ```

* On peut maintenant faire un test en essayant d'accéder le endpoint.
    ``` 
    curl $GATEWAY_URL/customer
    ```

    On devrait recevoir le message d'error suivant:
    ```
    customer =``` UnknownHostException: preference
    ```

* On peut aussi faire une révision des logs pour voir l'erreur.
    ``` 
    stern "customer-\w" -c customer
    ```
___

## Déploiement de Preference 

* Déploiement de l'application
    ```
    oc create -f manifest/kubernetes/preference/deployment.yaml -n demo
    ```
* Création du service
    ``` 
    oc create -f manifest/kubernetes/preference/service.yaml -n demo
    ```

* On peut maintenant faire un test en essayant d'accéder le endpoint.
    ``` 
    curl $GATEWAY_URL/customer
    ```

    On devrait recevoir le message d'error suivant:
    ```
    customer =``` Error: 503 - preference =``` UnknownHostException: recommendation
    ```

* On peut aussi faire une révision des logs pour voir l'erreur.
    ``` 
    stern "preference-\w" -c preference
    ```
___

## Déploiement de Recommendation 

* Déploiement de l'application
    ```
    oc create -f manifest/kubernetes/recommendation/deployment.yaml -n demo
    ```

* Création du service
    ```
    oc create -f manifest/kubernetes/recommendation/service.yaml -n demo
    ```

* On peut maintenant faire un test en essayant d'accéder le endpoint.
    ```
    curl $GATEWAY_URL/customer
    ```

    On devrait recevoir le message suivant:
    ```
    customer =``` preference =``` recommendation v1 from 'recommendation-v1-6cf5ff55d9-7zbj8': 1
    ```

* On peut aussi faire une révision des logs pour voir l'erreur.
    ``` 
    stern "recommendation-\w" -c recommendation
    ```


---
Maintenant que nous avons installé la Service Mesh, créer le porject et installer 3 différents applications. Amusons nous avec la ServiceMesh pour bien comprendre ses capacitées.

[Démo Obervabilité](observability.md)