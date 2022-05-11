#!/bin/bash

oc delete  authorizationpolicies customer-viewer -n demo
oc delete  authorizationpolicies deny-all -n demo
oc delete  authorizationpolicies preference-viewer -n demo
oc delete  authorizationpolicies recommendation-viewer -n demo