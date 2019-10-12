echo "###### MutatingWebHookConfiguration ######"
kubectl describe MutatingWebhookConfiguration
echo
echo "###### Injector Details ######"
injector_pod_name=$(kubectl -n injectors get pods | grep sidecar-injector | awk '{print $1}')
kubectl -n injectors describe pod $injector_pod_name
echo
echo "###### Injector-enabled Namespaces ######"
kubectl get ns -L conjur-sidecar-injector
