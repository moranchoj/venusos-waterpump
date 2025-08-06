# Documentació Tècnica - Sistema de Control de Bomba d'Aigua

## Arquitectura del Sistema

### Descripció General
El sistema implementa un control automatitzat d'una bomba d'aigua que transfereix aigua d'un dipòsit inferior (A) a un dipòsit superior (B) utilitzant Venus OS, Node-RED i components hardware especialitzats.

### Components del Sistema

#### Hardware
- **Raspberry Pi 4B**: Controlador principal amb Venus OS
- **HAT PiRelay v2**: Interface de control de relés
- **GX Tank 140**: Monitor de nivells de dipòsits
- **Sondes 4-20mA**: Sensors de nivell per cada dipòsit
- **Bomba d'aigua**: Actuador principal connectat al relé 1

#### Software
- **Venus OS Large 3.64**: Sistema operatiu base
- **Node-RED**: Plataforma d'automatització i dashboard
- **RpiGpioSetup**: Paquet per control GPIO
- **Venus OS D-Bus**: Interface directa per accés a dades de dispositius

## Lògica de Control

### Algoritme Principal

#### Condicions d'Arrencada (AND Logic)
```
IF (Tank_A_Level > 10%) AND (Tank_B_Level < 85%)
THEN Start_Pump()
```

#### Condicions de Parada (OR Logic - Prioritària)
```
IF (Tank_A_Level < 10%) OR (Tank_B_Level >= 100%)
THEN Stop_Pump()
```

### Implementació en Node-RED

#### Flow Principal
1. **Venus OS Input Nodes**: Reben nivells dels dipòsits directament via D-Bus
2. **Processing Functions**: Processen i emmagatzemen dades
3. **Control Logic Function**: Implementa l'algoritme de control
4. **GPIO Output Node**: Controla el relé de la bomba
5. **Dashboard Nodes**: Visualització i control manual

#### Funcions Clau

##### Process Tank Level
```javascript
// Venus OS input provides the value directly in msg.payload
var level = parseFloat(msg.payload.value || msg.payload);
if (!isNaN(level)) {
    flow.set('tankA_level', level);
    msg.payload = level;
    msg.topic = "Tank A Level";
    node.log("Tank A Level updated: " + level + "%");
    node.send([msg, {payload: "check_control"}]);
}
```

##### Control Logic
```javascript
var tankA_level = flow.get('tankA_level') || 0;
var tankB_level = flow.get('tankB_level') || 0;
var currentPumpState = flow.get('pump_state') || false;

var shouldStart = (tankA_level > 10) && (tankB_level < 85);
var shouldStop = (tankA_level < 10) || (tankB_level >= 100);

// Priority: Stop conditions override start conditions
if (shouldStop) {
    newPumpState = false;
    node.log("Pump stopped (Direct Venus OS) - Tank A: " + tankA_level + "%, Tank B: " + tankB_level + "%");
} else if (shouldStart && !currentPumpState) {
    newPumpState = true;
    node.log("Pump started (Direct Venus OS) - Tank A: " + tankA_level + "%, Tank B: " + tankB_level + "%");
}
```

## Interfície Venus OS D-Bus

### Serveis de Venus OS

#### Accés Directe (Sense MQTT)
- `com.victronenergy.tank.ttyUSB0/Level`: Nivell dipòsit inferior (A)
- `com.victronenergy.tank.ttyUSB1/Level`: Nivell dipòsit superior (B)

#### Configuració dels Nodes
```json
{
    "service": "com.victronenergy.tank.ttyUSB0",
    "path": "/Level",
    "serviceObj": {
        "service": "com.victronenergy.tank.ttyUSB0",
        "name": "Tank A - Lower Tank"
    }
}
```

### Format de Missatges

#### Nivells de Dipòsits (Venus OS D-Bus)
```json
{
    "value": 75.5,
    "timestamp": 1701432000000
}
```

## Control GPIO

### Configuració del Relé

#### Pin Assignment
- **GPIO Pin 7**: Control del relé 1 (bomba d'aigua)
- **Logic**: HIGH = Relé tancat (bomba ON), LOW = Relé obert (bomba OFF)

#### Node-RED GPIO Configuration
```json
{
    "pin": "7",
    "set": true,
    "level": "0",
    "out": "out"
}
```

## Dashboard Web

### Components d'Interfície

#### Grup de Monitorització
1. **Tank A Gauge**: 
   - Rang: 0-100%
   - Colors: Vermell (<10%), Taronja (10-50%), Verd (>50%)
   
2. **Tank B Gauge**:
   - Rang: 0-100%
   - Colors: Verd (<85%), Taronja (85-95%), Vermell (>95%)

3. **Pump Status Text**: Estat textual de la bomba
4. **Pump LED**: Indicador visual LED

#### Grup de Control Manual
1. **Manual Override Switch**: Activa/desactiva mode manual
2. **Manual Pump Control**: Control manual de la bomba

### Accés al Dashboard
- URL: `http://venus_ip:1880/ui`
- Títol: "Water Pump System"

## Seguretat i Fiabilitat

### Característiques de Seguretat

#### Protecció contra Funcionament en Sec
- Verificació contínua del nivell del dipòsit inferior
- Parada automàtica si el nivell baixa del 10%

#### Protecció contra Sobreompliment
- Parada automàtica si el dipòsit superior arriba al 100%
- Límit de seguretat al 85% per a l'arrencada

#### Mode Manual d'Emergència
- Control manual independent de l'automàtic
- Override de seguretat per manteniment

### Gestió d'Errors

#### Validació de Dades
```javascript
// Venus OS input provides the value directly in msg.payload
var level = parseFloat(msg.payload.value || msg.payload);
if (!isNaN(level)) {
    // Process valid data
    node.log("Tank Level updated: " + level + "%");
} else {
    node.warn("Invalid level received: " + JSON.stringify(msg.payload));
}
```

#### Logging i Diagnòstics
- Logs automàtics dels canvis d'estat
- Registre de condicions d'arrencada i parada
- Missatges de debug per troubleshooting

## Rendiment i Optimització

### Freqüència d'Actualització
- **Lectures de nivell**: Temps real (segons disponibilitat D-Bus)
- **Avaluació de control**: A cada canvi de nivell
- **Actualització dashboard**: Instantània

### Recursos del Sistema
- **CPU**: Baix impacte (<5% ús continu)
- **Memòria**: ~50MB per Node-RED + flows
- **Xarxa**: Sense tràfic MQTT (només local D-Bus)

## API i Integració

### Context Variables (Node-RED)
```javascript
// Variables globals del flow
flow.get('tankA_level')      // Nivell dipòsit A (%)
flow.get('tankB_level')      // Nivell dipòsit B (%)
flow.get('pump_state')       // Estat bomba (boolean)
flow.get('manual_override')  // Mode manual (boolean)
```

### Endpoints d'Integració
- **Node-RED Admin**: `http://venus_ip:1880`
- **Dashboard**: `http://venus_ip:1880/ui`
- **Venus OS D-Bus**: Local interface (no network access needed)

## Backup i Recuperació

### Estratègia de Backup
1. **Configuració Node-RED**: Flows i settings
2. **Configuració del sistema**: Fitxers de configuració
3. **Scripts**: Eines de backup/restore

### Procediment de Restore
```bash
./scripts/backup-restore.sh restore backup_name
```

## Monitorització i Manteniment

### Indicadors de Salut del Sistema
- Connectivitat Venus OS D-Bus
- Lectures dels sensors
- Estat del relé
- Funcionament de Node-RED

### Manteniment Preventiu
- **Setmanal**: Verificació de funcionament
- **Mensual**: Calibratge de sensors
- **Trimestral**: Neteja de connexions

### Troubleshooting

#### Problemes Comuns i Solucions

1. **No es reben dades dels dipòsits**
   - Verificar connexions GX Tank 140
   - Comprovar serveis Venus OS D-Bus
   - Revisar calibratge sensors

2. **Relé no funciona**
   - Verificar pin GPIO 7
   - Comprovar HAT PiRelay v2
   - Revisar RpiGpioSetup

3. **Dashboard no accessible**
   - Verificar servei Node-RED
   - Comprovar port 1880
   - Revisar configuració de xarxa