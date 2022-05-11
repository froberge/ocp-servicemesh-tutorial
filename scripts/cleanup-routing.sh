#!/bin/bash

oc delete virtualservice recommendation -n demo

oc delete destinationrule recommendation -n demo