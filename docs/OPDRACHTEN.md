

# Week 5
# deel 1
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

[WARN] 5.2.7 Minimize the admission of root containers (Manual)
[WARN] 5.3.2 Ensure that all Namespaces have NetworkPolicies defined (Manual)
[WARN] 5.4.1 Prefer using Secrets as files over Secrets as environment variables (Manual)

ContainerD security measure

config: /var/lib/rancher/k3s/agent/etc/containerd/config.toml
Hier staat enable_unprivileged_ports = true en enabled_unprivileged_icmp = true.

TODO: Vragen aan Henk of de check opnieuw moet slagen of dat je alleen moet antonen wat je gedaan hebt

## deel 2
self-sigend certificaat creëren: openssl req -x509 -nodes -days 365 -newkey rsa:2048   -keyout tls.key -out tls.crt   -subj "/CN=studentapp.local/O=DevSecOps" -addext "subjectAltName = DNS:studentapp.local"
ingress-controller installeren
ingress-nginx.yaml aanmaken en laten redirecten naar nginx-service op poort 5000
self-signed certificaat in trusted root op laptop

## deel 3
Network policy zodat de student-app alleen bereikbaar is op poort 5000.
How-to-test: Dockerfile veranderen naar EXPOSE 5001 en containerport wijzigen naar 5001.
Verwacht resultaat: Kubernetes weigert de verbinding omdat de netwerkPolicy resource alleen ingress op poort 5000 toestaat naar pods met het label app=student-app
