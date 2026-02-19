# CO2_RAPL
Script utilisant RAPL pour estimer l'empreinte carbone d'un serveur Linux
# 🌍 Moniteur de Consommation CPU et Émissions CO2

Script bash en temps réel pour surveiller la consommation énergétique du CPU et estimer les émissions de CO2 associées.

## 📋 Prérequis

- **Système d'exploitation** : Linux
- **Processeur** : Intel (ou tout processeur supporté par RAPL)
- **Permissions** : Accès root ou sudo
- **Dépendances** : `awk`, `bash`

## 🔧 Installation de RAPL

### Vérifier la disponibilité de RAPL

```bash
ls /sys/class/powercap/intel-rapl:0/
```

Si le dossier existe, RAPL est déjà disponible sur votre système.

### Charger le module RAPL (si nécessaire)

```bash
sudo modprobe intel_rapl_msr
```

Pour charger automatiquement au démarrage :

```bash
echo "intel_rapl_msr" | sudo tee /etc/modules-load.d/intel-rapl.conf
```

### Configurer les permissions

Pour éviter d'utiliser `sudo` à chaque exécution :

```bash
sudo chmod -R a+r /sys/class/powercap/intel-rapl:0/
```

Ou créer une règle udev permanente :

```bash
echo 'SUBSYSTEM=="powercap", KERNEL=="intel-rapl:*", MODE="0444"' | sudo tee /etc/udev/rules.d/99-rapl.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## 🚀 Installation du script

```bash
git clone https://github.com/votre-username/cpu-co2-monitor.git
cd cpu-co2-monitor
chmod +x monitor.sh
```

## 💻 Utilisation

```bash
./monitor.sh
```

Le script affichera en temps réel :
- ⚡ La consommation CPU en Watts
- 🌍 Les émissions de CO2 estimées en µg/s

### Exemple de sortie

```
⚡ Consommation CPU : 15.2340 W | 🌍 CO2 estimé : 253.9000 µg/s
⚡ Consommation CPU : 18.5670 W | 🌍 CO2 estimé : 309.4500 µg/s
```

## ⚙️ Configuration

Vous pouvez modifier les paramètres dans le script :

- `CO2_FACTOR` : Facteur d'émission CO2 (défaut : 0.06 kg CO2/kWh pour la France)
- `SAMPLE_INTERVAL` : Intervalle d'échantillonnage en secondes (défaut : 1)

## 🌐 Facteurs CO2 par pays

| Pays | Facteur (kg CO2/kWh) |
|------|----------------------|
| France | 0.06 |
| Allemagne | 0.40 |
| USA | 0.45 |
| Chine | 0.55 |
| Norvège | 0.02 |

## 🐛 Dépannage

### Erreur : "Permission denied"

```bash
sudo chmod -R a+r /sys/class/powercap/intel-rapl:0/
```

### Erreur : "No such file or directory"

Votre processeur ne supporte pas RAPL ou le module n'est pas chargé :

```bash
sudo modprobe intel_rapl_msr
```

### Vérifier les processeurs compatibles

RAPL est disponible sur les processeurs Intel depuis Sandy Bridge (2011) et sur certains processeurs AMD Ryzen.

```bash
lscpu | grep "Model name"
```

## 📊 Limitations

- Les mesures concernent uniquement le package CPU (pas le GPU, RAM, etc.)
- Le facteur CO2 est une estimation basée sur le mix énergétique national
- La précision dépend du support matériel RAPL

## 📝 Licence

MIT License

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.
