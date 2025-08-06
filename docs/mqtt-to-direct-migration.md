# Migració de MQTT a Integració Directa Venus OS

## Resum dels Canvis

Aquest document explica els canvis implementats per eliminar la dependència del broker MQTT i migrar a una integració directa amb Venus OS utilitzant D-Bus.

## Motivació

El sistema original utilitzava MQTT per obtenir les dades dels nivells dels dipòsits del GX Tank 140. Com que:
- Totes les dades són locals al sistema Venus OS
- No cal comunicació amb dispositius externs
- MQTT afegeix una capa d'abstracció innecessària

S'ha implementat l'accés directe a les dades via D-Bus per simplificar l'arquitectura i millorar la fiabilitat.

## Canvis Implementats

### 1. Nodes de Node-RED

#### Abans (MQTT):
```json
{
    "type": "mqtt in",
    "topic": "N/+/tank/0/Level",
    "broker": "venus-broker"
}
```

#### Després (Venus OS Direct):
```json
{
    "type": "victron-input-custom",
    "service": "com.victronenergy.tank.ttyUSB0",
    "path": "/Level"
}
```

### 2. Processament de Dades

#### Abans:
```javascript
var level = parseFloat(msg.payload);
```

#### Després:
```javascript
// Venus OS input pot proporcionar l'objecte o el valor directe
var level = parseFloat(msg.payload.value || msg.payload);
```

### 3. Configuració del Sistema

#### Abans (`system-config.json`):
```json
"mqtt": {
    "broker": "localhost",
    "port": 1883,
    "topics": {
        "tank_a_level": "N/+/tank/0/Level",
        "tank_b_level": "N/+/tank/1/Level"
    }
}
```

#### Després:
```json
"venus_os_integration": {
    "method": "direct_dbus",
    "tank_services": {
        "tank_a_service": "com.victronenergy.tank.ttyUSB0",
        "tank_b_service": "com.victronenergy.tank.ttyUSB1",
        "tank_path": "/Level"
    }
}
```

## Avantatges de la Nova Implementació

### 1. Simplicitat
- Eliminació del broker MQTT
- Accés directe a les dades
- Menys components per mantenir

### 2. Fiabilitat
- Sense dependències de xarxa interna
- Connexió directa via D-Bus
- Menys punts de fallada

### 3. Rendiment
- Latència reduïda
- Menys consum de recursos
- Accés més eficient a les dades

### 4. Manteniment
- Configuració més simple
- Menys troubleshooting necessari
- Arquitectura més clara

## Serveis Venus OS Utilitzats

### GX Tank 140 - Dipòsit Inferior (A)
- **Servei**: `com.victronenergy.tank.ttyUSB0`
- **Path**: `/Level`
- **Tipus**: `float` (percentatge 0-100)

### GX Tank 140 - Dipòsit Superior (B)
- **Servei**: `com.victronenergy.tank.ttyUSB1`
- **Path**: `/Level`
- **Tipus**: `float` (percentatge 0-100)

## Lògica de Control (Sense Canvis)

La lògica de control de la bomba **NO ha canviat**:

### Condicions d'Arrencada:
- Dipòsit inferior > **10%**
- **I** Dipòsit superior < **85%**

### Condicions de Parada:
- Dipòsit inferior < **10%**
- **O** Dipòsit superior ≥ **100%**

### Prioritat:
Les condicions de parada tenen prioritat sobre les d'arrencada.

## Dashboard i Interfície

### Elements Sense Canvis:
- Gàlgues de nivell dels dipòsits
- Indicadors d'estat de la bomba
- Controls manuals
- LED de visualització

### Funcionalitat Conservada:
- Monitorització en temps real
- Control manual override
- Alertes i proteccions de seguretat
- Interfície web completa

## Verificació del Sistema

### Test Automàtic:
```bash
./scripts/test-system.sh
```

### Verificacions Manuals:
1. **Lectura de dades**: Confirmar que es reben dades dels dipòsits
2. **Control logic**: Verificar que la bomba respon correctament
3. **Dashboard**: Comprovar que tots els elements funcionen
4. **Manual override**: Testar el control manual

## Troubleshooting

### Si no es reben dades:
1. Verificar connexions GX Tank 140
2. Comprovar serveis Venus OS: `dbus -y com.victronenergy.tank.*`
3. Revisar logs Node-RED per errors de connexió

### Si el control no funciona:
1. Verificar que les dades arribin al flow
2. Comprovar logs de control logic
3. Verificar connexió GPIO al relé

## Compatibilitat

### Versions Venus OS:
- **Mínima**: Venus OS 3.64
- **Recomanada**: Venus OS Large 3.64 o superior

### Node-RED:
- Nodes Venus OS han d'estar disponibles
- Típicament inclosos amb Venus OS Large

## Migració d'Instal·lacions Existents

### Passos per migrar:
1. Fer backup del flow actual
2. Importar el nou flow sense MQTT
3. Verificar configuració GX Tank 140
4. Provar funcionament en mode manual
5. Activar mode automàtic

### Rollback:
En cas de problemes, es pot tornar al flow amb MQTT restauran
t el backup anterior.

---

**Data d'implementació**: Desembre 2024  
**Versió del sistema**: 2.0.0  
**Estat**: Implementat i validat