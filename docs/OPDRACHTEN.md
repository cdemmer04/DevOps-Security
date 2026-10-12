# Algemeen
IP worker: 13.222.75.52

# Week 5

## deel 1
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml

[WARN] 5.2.7 Minimize the admission of root containers (Manual)
Status: deels opgelost. Waarom? omdat dit klakkeloos op system namespaces toepassen onverstandig is. 
Validatie: kubectl get namespace --show-labels

[WARN] 5.3.2 Ensure that all Namespaces have NetworkPolicies defined (Manual)
Status: opgelost
Validatie: kubectl get networkpolicy --all-namespaces
Toelichting: moet per namespace/applicatie worden beoordeeld. Voorbeeld van student-app is eenvoudig. Voor andere onderdelen moet onderzocht worden wat de impact is.

[WARN] 5.4.1 Prefer using Secrets as files over Secrets as environment variables (Manual)
Status: compliant (met uitzondering van Harbor)
Validatie: kubectl get all -o jsonpath='{range .items[?(@..secretKeyRef)]} {.kind} 
{.metadata.name} {"\n"}{end}' -A

Toelichting: Deze wordt niet automatisch gescand of hij goed is. De risico's en impact moeten door een organisatie zelf worden ingeschat.

ContainerD security measure
Maatregel: aanpassen configuratie zodat communicatie met registries alleen via tls mag verlopen
/etc/rancher/k3s/registries.yaml
https://docs.k3s.io/installation/private-registry#registries-configuration-file


TODO: Vragen aan Henk of de check opnieuw moet slagen of dat je alleen moet antonen wat je gedaan hebt

## deel 2
self-sigend certificaat creëren: openssl req -x509 -nodes -days 365 -newkey rsa:2048   -keyout tls.key -out tls.crt   -subj "/CN=studentapp.local/O=DevSecOps" -addext "subjectAltName = DNS:studentapp.local"
ingress-controller installeren
ingress-nginx.yaml aanmaken en laten redirecten naar nginx-service op poort 5000
self-signed certificaat in trusted root op laptop

## deel 3
Network policy zodat de student-app alleen bereikbaar is op poort 5000.
How-to-test: Dockerfile veranderen zodat applicatie luistert op poort 5001 en containerport in deployment en service wijzigen naar 5001
Verwacht resultaat: Kubernetes weigert de verbinding omdat de netwerkPolicy resource alleen ingress op poort 5000 toestaat naar pods met het label app=student-app

# Week 6

## deel 1
admin passwd: kubectl get secret monitoring-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
alert rules:
- critical vulnerability vanuit trivy
- CIs kubernetes benchmark non-compliant
- Hoeveel 401 requests zijn er op de API? Test: curl -k   -H "Authorization: Bearer $TOKEN"   "$APISERVER/api/v1/namespaces/default/secrets"

# Week 7

## Deel 1
Drie maatregelen:
- 1.5.2 Ensure fs.protected_symlinks is configured (Automated)
    Doel: Het voorkomen dat een symlink wordt gemaakt in sticky world-writable directories.
    Verificatie: sysctl fs.protected_symlinks moet fs.protected_symlinks = 1 teruggeven
- 1.2.1.2 Ensure weak dependencies are configured (Automated)
    Doel: Niet automatisch niet-noodzakelijke packages installeren. Dit verkleint het aanvalsoppervlak.
    Verificatie: /usr/bin/apt-config dump | /usr/bin/grep "APT::Install-"
- 1.2.1.5 Ensure access to /etc/apt/auth.conf.d directory is
configured (Automated)
    Doel: /etc/apt/auth.conf.d/ bevat configuratiebestanden die mogelijk gevoelige informatie kunnen bevatten.
    Verificatie: stat -Lc 'Access: (%a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' /etc/apt/auth.conf.

## deel 2
kubectl apply -f ./serviceaccount.yaml: deze file bevat service account, cluster role, clusterrole binding en secretinformatie
Token ophalen: kubectl get secret student-app-serviceaccount-token -o=jsonpath='{.data.token}' | base64 --decode

## extra
Met kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' haal je de configuratie op. Hierbij selecteer je specifiek op het CA-certificaat.
