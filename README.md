# Sistema de Control de Bomba d'Aigua - Venus OS

**Control automatitzat d'una bomba entre dos dipòsits utilitzant Node-RED, Raspberry Pi i Venus OS**

[![Venus OS](https://img.shields.io/badge/Venus%20OS-3.64-blue)](https://github.com/victronenergy/venus)
[![Node-RED](https://img.shields.io/badge/Node--RED-Compatible-red)](https://nodered.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## 🎯 Descripció del Projecte

Aquest sistema implementa el control automàtic d'una bomba que impulsa aigua del dipòsit inferior (A) al dipòsit superior (B), proporcionant:

- **Control automatitzat** basat en nivells dels dipòsits
- **Interfície web** per monitorització i control manual
- **Integració completa** amb Venus OS i MQTT
- **Seguretat i fiabilitat** amb proteccions múltiples

## 🏗️ Components del Sistema

### Hardware Necessari
- **Raspberry Pi 4B** amb Venus OS Large 3.64
- **HAT PiRelay v2** per control de relés
- **GX Tank 140** per monitorització de nivells
- **2 Sondes de nivell 4-20mA** (una per dipòsit)
- **Bomba d'aigua** connectada al relé 1

### Software Necessari
- Venus OS Large 3.64
- Node-RED (inclòs amb Venus OS)
- Paquet RpiGpioSetup
- MQTT Broker (inclòs amb Venus OS)

## ⚙️ Lògica de Control

### Condicions d'Arrencada
La bomba **arrenca** (relé 1 tancat) quan:
- 📊 Dipòsit inferior > **10%**
- 📊 Dipòsit superior < **85%**

### Condicions de Parada
La bomba **para** (relé 1 obert) quan:
- 📊 Dipòsit inferior < **10%** (protecció contra sec)
- 📊 Dipòsit superior ≥ **100%** (protecció contra sobreompliment)

> ⚠️ **Nota**: Les condicions de parada tenen prioritat sobre les d'arrencada

## 📱 Dashboard Web

### Funcionalitats de Monitorització
- **Gàlgues visuals** dels nivells de cada dipòsit
- **Indicadors d'estat** de la bomba (text i LED)
- **Historial** de funcionament en temps real

### Controls Manuals
- **Mode override** per control manual
- **Control directe** de la bomba per manteniment
- **Indicadors de seguretat** actius

### Accés al Dashboard
```
http://[IP_VENUS_OS]:1880/ui
```

## 🚀 Instal·lació Ràpida

### 1. Preparació del Sistema
```bash
# Instal·lar RpiGpioSetup
wget https://github.com/kwindrem/RpiGpioSetup/archive/main.zip
unzip main.zip && cd RpiGpioSetup-main
./setup
```

### 2. Activar Node-RED
1. Accedir a Venus OS: `http://[IP_VENUS_OS]`
2. **Settings** > **Services** > **Node-RED** > **Enabled**
3. Reiniciar el sistema

### 3. Instal·lar el Flow
```bash
# Clonar el repositori
git clone https://github.com/moranchoj/venusos-waterpump.git
cd venusos-waterpump

# Instal·lar automàticament
./scripts/backup-restore.sh install
```

### 4. Configurar Hardware
- Connectar HAT PiRelay v2 a la Raspberry Pi
- Configurar GX Tank 140 per als dipòsits
- Connectar sondes 4-20mA als dipòsits
- Connectar bomba al relé 1

## 📁 Estructura del Projecte

```
venusos-waterpump/
├── flows/
│   └── water-pump-control.json     # Flow principal de Node-RED
├── docs/
│   ├── installation-guide.md       # Guia d'instal·lació detallada
│   └── technical-documentation.md  # Documentació tècnica
├── config/
│   └── system-config.json          # Configuració del sistema
├── scripts/
│   └── backup-restore.sh           # Script de backup/restore
└── README.md                       # Aquest fitxer
```

## 🔧 Configuració Avançada

### Topics MQTT
- **Dipòsit A**: `N/+/tank/0/Level`
- **Dipòsit B**: `N/+/tank/1/Level`

### GPIO Configuration
- **Relé 1**: Pin GPIO 7 (HAT PiRelay v2)

### Personalització
Editar `config/system-config.json` per modificar:
- Nivells de control (10%, 85%, 100%)
- Configuració MQTT
- Paràmetres de seguretat

## 🛡️ Seguretat i Fiabilitat

### Proteccions Implementades
- ✅ **Protecció contra sec**: Parada automàtica si dipòsit inferior < 10%
- ✅ **Protecció contra sobreompliment**: Parada si dipòsit superior ≥ 100%
- ✅ **Mode manual d'emergència**: Control independent per manteniment
- ✅ **Validació de dades**: Verificació de lectures dels sensors
- ✅ **Logging complet**: Registre d'events i errors

### Monitorització
- Estat dels sensors en temps real
- Historial de funcionament
- Alertes automàtiques
- Diagnòstics del sistema

## 📚 Documentació

### Guies Disponibles
- 📖 [**Guia d'Instal·lació**](docs/installation-guide.md): Instal·lació pas a pas
- 🔧 [**Documentació Tècnica**](docs/technical-documentation.md): Detalls tècnics i API

### Scripts Útils
- 💾 [**Backup/Restore**](scripts/backup-restore.sh): Gestió de còpies de seguretat

## 🚨 Troubleshooting

### Problemes Comuns

#### Node-RED no accessible
```bash
systemctl status nodered
systemctl restart nodered
```

#### No es reben dades dels dipòsits
- Verificar connexions GX Tank 140
- Comprovar calibratge de sondes
- Revisar topics MQTT

#### Relé no funciona
- Verificar instal·lació RpiGpioSetup
- Comprovar connexions HAT PiRelay v2
- Revisar configuració GPIO

## 🤝 Contribucions

Les contribucions són benvingudes! Per contribuir:

1. Fork del repositori
2. Crear branch per la funcionalitat
3. Commit dels canvis
4. Push al branch
5. Crear Pull Request

## 📄 Llicència

Aquest projecte està llicenciat sota la llicència MIT. Vegeu el fitxer [LICENSE](LICENSE) per a més detalls.

## 📞 Suport

Per assistència tècnica:
- 📋 [Crear issue](https://github.com/moranchoj/venusos-waterpump/issues)
- 📖 Revisar documentació
- 🔍 Comprovar logs del sistema

---

**Desenvolupat per al control eficient i segur de bombes d'aigua amb Venus OS** 🌊⚡
