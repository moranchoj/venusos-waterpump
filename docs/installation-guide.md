# Guia d'Instal·lació - Sistema de Control de Bomba d'Aigua

## Requisits del Sistema

### Hardware Necessari
- **Raspberry Pi 4B** amb Venus OS Large 3.64
- **HAT PiRelay v2** per control de relés
- **GX Tank 140** per mesura de nivells
- **2 Sondes de nivell 4-20mA** (una per cada dipòsit)
- **Bomba d'aigua** connectada al relé 1

### Software Necessari
- Venus OS Large 3.64
- Node-RED (inclòs amb Venus OS)
- Paquet RpiGpioSetup de GitHub

## Instal·lació Pas a Pas

### 1. Preparació de Venus OS

#### Instal·lació del Paquet RpiGpioSetup
```bash
# Connectar per SSH a la Raspberry Pi
ssh root@venus_ip

# Descarregar i instal·lar RpiGpioSetup
wget https://github.com/kwindrem/RpiGpioSetup/archive/main.zip
unzip main.zip
cd RpiGpioSetup-main
./setup
```

#### Activació de Node-RED
1. Accedir a la interfície web de Venus OS: `http://venus_ip`
2. Anar a **Settings** > **Services** > **Node-RED**
3. Activar Node-RED
4. Reiniciar el sistema

### 2. Configuració del Hardware

#### Connexió del HAT PiRelay v2
1. Muntar el HAT sobre la Raspberry Pi seguint les instruccions del fabricant
2. Verificar que el pin GPIO 19 està assignat al relé 1
3. Connectar la bomba d'aigua al relé 1

#### Configuració del GX Tank 140
1. Connectar el GX Tank 140 a la Raspberry Pi via USB o CAN
2. Configurar les entrades per a les dues sondes:
   - **Tank 0**: Dipòsit inferior (A)
   - **Tank 1**: Dipòsit superior (B)
3. Calibrar les sondes segons les especificacions del fabricant

#### Connexió de les Sondes de Nivell
1. Connectar la sonda del dipòsit inferior a l'entrada 0 del GX Tank 140
2. Connectar la sonda del dipòsit superior a l'entrada 1 del GX Tank 140
3. Verificar que les lectures 4-20mA es converteixen correctament a percentatges

### 3. Instal·lació del Flow de Node-RED

#### Importació del Flow
1. Accedir a Node-RED: `http://venus_ip:1880`
2. Anar al menú principal (☰) > **Import**
3. Copiar el contingut del fitxer `flows/water-pump-control.json`
4. Enganxar al diàleg d'importació i confirmar
5. Fer clic a **Deploy** per activar el flow

#### Verificació de la Configuració
1. Verificar que els nodes MQTT es connecten correctament
2. Comprovar que el node GPIO està configurat per al pin 19
3. Confirmar que el dashboard es mostra correctament

### 4. Configuració dels Topics MQTT

El sistema utilitza els següents topics MQTT de Venus OS:

#### Topics d'Entrada (Lectures de Nivells)
- `N/+/tank/0/Level` - Nivell del dipòsit inferior (A)
- `N/+/tank/1/Level` - Nivell del dipòsit superior (B)

#### Configuració del Broker MQTT
- **Host**: localhost (configurat automàticament)
- **Port**: 1883
- **Client ID**: Automàtic

### 5. Configuració de la Lògica de Control

La lògica de control està implementada i no requereix configuració addicional:

#### Condicions d'Arrencada
- Dipòsit inferior > 10%
- **I** Dipòsit superior < 85%

#### Condicions de Parada
- Dipòsit inferior < 10%
- **O** Dipòsit superior ≥ 100%

### 6. Verificació del Sistema

#### Test de Funcionament
1. Verificar lectures de nivells al dashboard
2. Simular condicions d'arrencada i parada
3. Comprovar el funcionament del relé
4. Verificar els indicadors del dashboard

#### Monitorització
El dashboard proporciona:
- **Gàlgues de nivell** per ambdós dipòsits
- **Indicador d'estat** de la bomba
- **LED visual** de l'estat de la bomba
- **Controls manual** per a manteniment

## Troubleshooting

### Problemes Comuns

#### Node-RED no es connecta
- Verificar que Node-RED està activat a Venus OS
- Comprovar l'accés al port 1880
- Reiniciar el servei Node-RED

#### No es reben dades dels dipòsits
- Verificar la configuració del GX Tank 140
- Comprovar les connexions de les sondes
- Revisar els topics MQTT

#### El relé no funciona
- Verificar la configuració del pin GPIO 19
- Comprovar la instal·lació del RpiGpioSetup
- Verificar les connexions del HAT PiRelay v2

#### Lectures incorrectes
- Calibrar les sondes de nivell
- Verificar el rang 4-20mA
- Comprovar la configuració del GX Tank 140

### Logs i Diagnòstics

#### Accés als Logs
```bash
# Logs de Venus OS
journalctl -f

# Logs específics de Node-RED
journalctl -u nodered -f
```

#### Debug de Node-RED
1. Activar els nodes de debug al flow
2. Monitoritzar la pestanya de debug
3. Verificar els missatges MQTT

## Manteniment

### Operacions Regulars
- Verificar el funcionament setmanal
- Comprovar les connexions físiques mensualment
- Actualitzar Venus OS segons recomanacions

### Mode Manual
El sistema inclou un mode manual per a manteniment:
1. Activar el **Control Manual** al dashboard
2. Utilitzar el **Bomba Manual** per controlar la bomba
3. Desactivar el mode manual per tornar al funcionament automàtic

## Suport

Per a assistència tècnica o problemes:
1. Revisar aquesta documentació
2. Comprovar els logs del sistema
3. Verificar la configuració del hardware
4. Contactar amb el suport tècnic si cal