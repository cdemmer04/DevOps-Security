

# Week 5
# deel 1
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

[WARN] 5.2.7 Minimize the admission of root containers (Manual)
[WARN] 5.3.2 Ensure that all Namespaces have NetworkPolicies defined (Manual)
[WARN] 5.4.1 Prefer using Secrets as files over Secrets as environment variables (Manual)

TODO: containerd controls toepassen 
TODO: Vragen aan Henk of de check opnieuw moet slagen of dat je alleen moet antonen wat je gedaan hebt

## deel 2
self-sigend certificaat creëren: openssl req -x509 -nodes -days 365 -newkey rsa:2048   -keyout tls.key -out tls.crt   -subj "/CN=studentapp.local/O=DevSecOps" -addext "subjectAltName = DNS:studentapp.local"
ingress-controller installeren
ingress-nginx.yaml aanmaken en laten redirecten naar nginx-service op poort 5000
self-signed certificaat in trusted root op laptop

## deel 3
TODO