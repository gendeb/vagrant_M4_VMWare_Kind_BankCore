#!/bin/bash

OUT=deps.mmd
echo "flowchart LR" > $OUT

# Iterate namespaces
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  echo "" >> $OUT
  echo "%% === Namespace: $ns ===" >> $OUT
  echo "subgraph $ns" >> $OUT

  # Capture PODS with their labels
  for pod in $(kubectl get pods -n $ns -o jsonpath='{.items[*].metadata.name}'); do
    echo "  ${ns}_${pod}[Pod: $pod]" >> $OUT
  done

  # Capture SERVICES and their selectors
  for svc in $(kubectl get svc -n $ns -o jsonpath='{.items[*].metadata.name}'); do

    selector=$(kubectl get svc $svc -n $ns -o jsonpath='{.spec.selector}' 2>/dev/null)

    # sanitize selector formatting
    sel_clean=$(echo $selector | sed 's/[{}]//g' | sed 's/,/ /g')

    echo "  ${ns}_${svc}[(Service: $svc)]" >> $OUT

    # Create dependency edges: service -> pod it selects
    if [ ! -z "$sel_clean" ]; then
      for pod in $(kubectl get pods -n $ns -l "$sel_clean" -o jsonpath='{.items[*].metadata.name}'); do
        echo "  ${ns}_${svc} --> ${ns}_${pod}" >> $OUT
      done
    fi
  done

  echo "end" >> $OUT
done

# ===== Ingress rules =====
echo "" >> $OUT
echo "%% === Ingress Routing ===" >> $OUT

for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  for ing in $(kubectl get ing -n $ns -o jsonpath='{.items[*].metadata.name}'); do
    # Capture backend service
    rules=$(kubectl get ing $ing -n $ns -o jsonpath='{.spec.rules[*].http.paths[*].backend.service.name}')
    for svc in $rules; do
      echo "ingress_${ing}[Ingress: $ing] --> ${ns}_${svc}" >> $OUT
    done
  done
done

# ===== Environment-variable based dependencies =====
echo "" >> $OUT
echo "%% === Env-based Dependencies ===" >> $OUT

for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do
  for pod in $(kubectl get pods -n $ns -o jsonpath='{.items[*].metadata.name}'); do
    envdump=$(kubectl exec -n $ns $pod -- printenv 2>/dev/null)
    for svc in $(kubectl get svc -A | awk '{print $2}' | tail -n +2); do
      svc_upper=$(echo $svc | tr '[:lower:]' '[:upper:]' | tr '-' '_')
      if echo "$envdump" | grep -q "${svc_upper}_SERVICE_HOST"; then
        target_ns=$(kubectl get svc -A | grep " $svc " | awk '{print $1}')
        echo "${ns}_${pod} --> ${target_ns}_${svc}" >> $OUT
      fi
    done
  done
done

echo "Dependency graph written to $OUT"
