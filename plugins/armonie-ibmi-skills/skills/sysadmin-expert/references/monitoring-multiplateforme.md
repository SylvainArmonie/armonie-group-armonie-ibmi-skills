# Monitoring Multi-Plateforme Linux et IBM i

## Architecture de monitoring unifiee

### Approche recommandee

```
┌─────────────────────────────────────────────────────────┐
│                    TABLEAU DE BORD                       │
│              Grafana / Zabbix / Datadog                  │
│         (Vue unifiee Linux + IBM i)                      │
└─────────────────┬───────────────────┬───────────────────┘
                  │                   │
    ┌─────────────▼──────┐  ┌────────▼──────────────┐
    │   Linux Agents      │  │   IBM i Collectors     │
    │ - Prometheus node   │  │ - IBM i Navigator      │
    │ - Telegraf          │  │ - SNMP (STRTCPSVR      │
    │ - collectd          │  │   *SNMP)               │
    │ - Zabbix agent      │  │ - Zabbix agent IBM i   │
    │ - journald export   │  │ - SQL Services QSYS2   │
    └─────────────────────┘  └────────────────────────┘
```

## Monitoring Linux (Debian/Ubuntu)

### Stack Prometheus + Grafana

```bash
# Installation Prometheus
apt install prometheus prometheus-node-exporter

# Le node_exporter collecte automatiquement :
# - CPU, RAM, disque, reseau
# - Systemd services
# - Filesystem usage
# - Network connections

# Configuration /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: 'linux-servers'
    static_configs:
      - targets:
        - 'srv-web01:9100'
        - 'srv-db01:9100'
        - 'srv-app01:9100'
    scrape_interval: 30s

# Installation Grafana
apt install grafana
systemctl enable --now grafana-server
# Acceder via http://serveur:3000
```

### Alerting avec Prometheus Alertmanager
```yaml
# /etc/prometheus/alert.rules.yml
groups:
  - name: system
    rules:
      - alert: HighCPU
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU > 90% sur {{ $labels.instance }}"

      - alert: DiskFull
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disque < 10% sur {{ $labels.instance }}"

      - alert: BackupStale
        expr: time() - node_textfile_mtime_seconds{file="backup_last_success.prom"} > 93600
        for: 1h
        labels:
          severity: critical
        annotations:
          summary: "Sauvegarde > 26h sur {{ $labels.instance }}"
```

### Monitoring avec journald et systemd
```bash
# Suivre les erreurs en temps reel
journalctl -p err -f

# Alertes sur les services critiques
systemctl is-failed --quiet nginx && echo "NGINX DOWN"
systemctl is-failed --quiet postgresql && echo "PG DOWN"

# Script de verification des services critiques
#!/bin/bash
SERVICES="nginx postgresql ssh cron"
for svc in $SERVICES; do
    if ! systemctl is-active --quiet $svc; then
        echo "ALERTE: $svc est inactif" | \
            mail -s "SERVICE DOWN: $svc" admin@entreprise.fr
    fi
done
```

## Monitoring IBM i

### Outils natifs
```
-- Etat du systeme (CPU, memoire, jobs)
WRKSYSSTS
WRKSYSACT

-- Jobs actifs
WRKACTJOB

-- Espace disque
WRKDSKSTS
WRKSYSSTS → %ASP utilise

-- Messages operateur
DSPMSG MSGQ(QSYSOPR)

-- Journal systeme
DSPLOG LOG(QHST)

-- Performance
WRKSYSSTS ASTLVL(*BASIC)
```

### SQL Services QSYS2 (monitoring moderne)

```sql
-- CPU et memoire via SQL
SELECT ELAPSED_CPU_USED, CONFIGURED_CPUS,
       MAIN_STORAGE_SIZE, SYSTEM_ASP_USED
FROM QSYS2.SYSTEM_STATUS_INFO;

-- Jobs actifs par sous-systeme
SELECT SUBSYSTEM, COUNT(*) AS NB_JOBS,
       SUM(CASE WHEN JOB_STATUS = 'MSGW' THEN 1 ELSE 0 END) AS MSGW
FROM TABLE(QSYS2.ACTIVE_JOB_INFO()) AS J
GROUP BY SUBSYSTEM
ORDER BY NB_JOBS DESC;

-- Espace disque par ASP
SELECT ASP_NUMBER, DISK_CAPACITY, DISK_STORAGE_USED_PERCENT
FROM QSYS2.ASP_INFO;

-- Derniers messages QSYSOPR
SELECT MESSAGE_ID, MESSAGE_TEXT, MESSAGE_TIMESTAMP
FROM QSYS2.MESSAGE_QUEUE_INFO
WHERE MESSAGE_QUEUE_NAME = 'QSYSOPR'
ORDER BY MESSAGE_TIMESTAMP DESC
FETCH FIRST 20 ROWS ONLY;

-- Jobs en MSGW (attente de message)
SELECT JOB_NAME, JOB_USER, JOB_NUMBER, SUBSYSTEM,
       FUNCTION, FUNCTION_TYPE
FROM TABLE(QSYS2.ACTIVE_JOB_INFO()) AS J
WHERE JOB_STATUS = 'MSGW';

-- PTF appliquees recemment
SELECT PTF_IDENTIFIER, PTF_IPL_ACTION, PRODUCT_ID,
       STATUS_TIMESTAMP
FROM QSYS2.PTF_INFO
WHERE STATUS_TIMESTAMP > CURRENT_TIMESTAMP - 30 DAYS
ORDER BY STATUS_TIMESTAMP DESC;
```

### SNMP sur IBM i
```
-- Demarrer l'agent SNMP
STRTCPSVR SERVER(*SNMP)

-- Configurer la communaute SNMP
CFGTCP → Option 20 (Configure SNMP)

-- Depuis Linux, interroger l'IBM i via SNMP
snmpwalk -v2c -c public ibmi-prod.entreprise.fr system
snmpget -v2c -c public ibmi-prod.entreprise.fr .1.3.6.1.4.1.2.6.4.5.1.0
```

### Zabbix pour IBM i
```
-- L'agent Zabbix est disponible pour IBM i via PASE
-- Installation via yum dans PASE :
PATH=/QOpenSys/pkgs/bin:$PATH
yum install zabbix-agent

-- Configuration /QOpenSys/etc/zabbix_agentd.conf
Server=zabbix-srv.entreprise.fr
ServerActive=zabbix-srv.entreprise.fr
Hostname=ibmi-prod
```

## Tableau de bord unifie

### Metriques a surveiller sur les DEUX plateformes

| Metrique | Linux | IBM i |
|----------|-------|-------|
| CPU | node_cpu_seconds_total | WRKSYSSTS / QSYS2.SYSTEM_STATUS |
| RAM | node_memory_MemAvailable | WRKSYSSTS / QSYS2.SYSTEM_STATUS |
| Disque | node_filesystem_avail | WRKDSKSTS / QSYS2.ASP_INFO |
| Reseau | node_network_receive/transmit | WRKTCPSTS |
| Processus/Jobs | node_procs_running | WRKACTJOB / QSYS2.ACTIVE_JOB_INFO |
| Erreurs | journalctl -p err | DSPMSG QSYSOPR / QSYS2.MESSAGE_QUEUE |
| Services | systemctl status | WRKSBS, WRKTCPSTS |
| Sauvegarde | Derniere sauvegarde OK | BRMS WRKCTLGBRM statut |
| Securite | fail2ban, auth.log | QAUDJRN, DSPAUTUSR |

### Script de health-check multi-plateforme
```bash
#!/bin/bash
# health-check.sh — Verification quotidienne Linux + IBM i
# Auteur : Sylvain AKTEPE - NOTOS/Armonie

IBMI_HOST="ibmi-prod.entreprise.fr"
IBMI_USER="QSECOFR"
REPORT="/tmp/healthcheck_$(date +%Y%m%d).txt"

echo "=== Health Check $(date) ===" > $REPORT

# --- Linux ---
echo "" >> $REPORT
echo "--- LINUX ---" >> $REPORT
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')" >> $REPORT
echo "RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')" >> $REPORT
echo "Disque /: $(df -h / | awk 'NR==2 {print $5 " utilise"}')" >> $REPORT
echo "Services KO: $(systemctl --failed --no-pager --plain | grep -c 'failed')" >> $REPORT
echo "Derniere sauvegarde: $(borg list --last 1 --format '{time}' /backup/borg-repo 2>/dev/null || echo 'N/A')" >> $REPORT

# --- IBM i ---
echo "" >> $REPORT
echo "--- IBM i ---" >> $REPORT
ssh ${IBMI_USER}@${IBMI_HOST} "system 'WRKSYSSTS OUTPUT(*PRINT)'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "IBM i: Accessible" >> $REPORT
    # Recuperer metriques via SQL
    ssh ${IBMI_USER}@${IBMI_HOST} "db2 \"SELECT ELAPSED_CPU_USED, SYSTEM_ASP_USED FROM QSYS2.SYSTEM_STATUS_INFO\"" >> $REPORT 2>/dev/null
else
    echo "IBM i: INACCESSIBLE !" >> $REPORT
fi

# Envoyer le rapport
cat $REPORT | mail -s "Health Check $(date +%Y-%m-%d)" admin@entreprise.fr
```

## Bonnes pratiques monitoring multi-plateforme

1. **Vue unifiee** — Un seul tableau de bord pour Linux ET IBM i
2. **Alertes coherentes** — Memes seuils de severite sur les deux plateformes
3. **Historique** — Conserver au moins 90 jours de metriques
4. **Automatisation** — Pas de verification manuelle pour les metriques standard
5. **Escalade** — Definir une matrice d'escalade claire (qui contacter, quand)
6. **Documentation** — Documenter les seuils, les contacts, et les procedures
7. **Tests** — Tester regulierement les alertes (declencher volontairement)
