#!/bin/bash
ROOK_WORKERS="talos-mk9-ylp talos-dn0-86j talos-gkm-6hn"

for i in $ROOK_WORKERS; do
  echo "Wiping $i"
  cat wipe-rook.yaml | sed -e "s/HOSTNAME/$i/g" | kubectl apply -f -
done

for i in $ROOK_WORKERS; do
  echo "Waiting for $i to complete"
  kubectl wait --timeout=900s --for=jsonpath='{.status.phase}=Succeeded' pod disk-wipe-$i -n kube-system
  # kubectl delete pod disk-wipe-$i
done
