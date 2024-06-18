echo "patching digibank namespace"

kubectl patch deployment digital-bank-front -n digibank -p '{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-java":"default/splunk-otel-collector"}}}}}'
kubectl patch deployment digital-bank-credit-deployment -n digibank -p '{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-java":"default/splunk-otel-collector"}}}}}'



echo "patching digibank-backends namespace"

kubectl patch deployment digital-bank-backends-atm-java-deployment -n digibank-backends -p '{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-java":"default/splunk-otel-collector"}}}}}'
kubectl patch deployment digital-bank-backends-visa-java-deployment -n digibank-backends -p '{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-java":"default/splunk-otel-collector"}}}}}'

kubectl patch deployment digital-bank-backends-atm-node-deployment -n digibank-backends -p '{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-nodejs":"default/splunk-otel-collector"}}}}}'
kubectl patch deployment digital-bank-backends-visa-node-deployment -n digibank-backends -p '{"spec":{"template":{"metadata":{"annotations":{"instrumentation.opentelemetry.io/inject-nodejs":"default/splunk-otel-collector"}}}}}'


