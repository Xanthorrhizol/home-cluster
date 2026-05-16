#!/bin/bash
set -e

helm uninstall reflector --namespace kube-system
