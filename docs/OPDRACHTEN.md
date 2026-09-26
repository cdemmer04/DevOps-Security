kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

[WARN] 5.2.7 Minimize the admission of root containers (Manual)
[WARN] 5.3.2 Ensure that all Namespaces have NetworkPolicies defined (Manual)
[WARN] 5.4.1 Prefer using Secrets as files over Secrets as environment variables (Manual)

self-sigend certificaat creëren: openssl req -x509 -nodes -days 365 -newkey rsa:2048   -keyout tls.key -out tls.crt   -subj "/CN=studentapp.local/O=StudentApp"
ingress-controller installeren
ingress-nginx.yaml aanmaken en laten redirecten naar nginx-service op poort 5000
self-signed certificaat in trusted root op laptop
