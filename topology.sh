#!/bin/bash

OUT=cluster-topology.mmd

echo "flowchart TB" > $OUT

# List namespaces
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  echo "" >> $OUT
  echo "  subgraph $ns" >> $OUT

  # Deployments
  for d in $(kubectl -n $ns get deploy -o jsonpath='{.items[*].metadata.name}'); do
    echo "      ${ns}_${d}[Deployment: $d]" >> $OUT
  done

  # StatefulSets
  for s in $(kubectl -n $ns get sts -o jsonpath='{.items[*].metadata.name}'); do
    echo "      ${ns}_${s}[StatefulSet: $s]" >> $OUT
  done

  # Services
  for svc in $(kubectl -n $ns get svc -o jsonpath='{.items[*].metadata.name}'); do
    echo "      ${ns}_${svc}[(Service: $svc)]" >> $OUT
  done

  echo "  end" >> $OUT
done

echo "Topology written to $OUT"
