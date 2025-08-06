# venusos-waterpump
Sistema de control d'una bomba d'aigua amb venus os
# Sistema de control d'una bomba d'aigua amb venus os

**Control automatitzat d'una bomba entre dos dipòsits utilitzant Node-RED, Raspberry Pi i Vernus OS**

## Descripció del Projecte

Aquest sistema implementa el control automàtic d'una bomba que impulsa aigua del dipòsit inferior (A) al dipòsit superior (B), utilitzant:

- **Raspberry Pi 4B** amb HAT PiRelay v2 per control de relés i amb venus os large 3.64
- GX Tank 140 conectat a la raspberry
- Package RpiGpioSetup de GitHub instal·lat al venus OS
- Bomba d'aigua conectada al relay 1 del de la raspberry
- Dues sondes de nivell de corrent de 4 a 20 ma conectades al GX Tank 140
- **Node-RED** per l'automatització i dashboard de control

## Funcionalitats Principals
Cada diposit te una sonda de nivell conectada al GX Tank. 
EL VEnus OS calcula de forma instantanea per cada diposit el seu nivell d'emplenatje. 
El sistema ha d'arancar i parar la bomba tancant i obrint el relay 1 segon una logica determinada
La logica es la seguent:
La bomba ha d'arrancar (tancar el realy1) si el nivell del dipsoit inferior esta per sobre del 10% i el nivell del diposit superior esta per sota del 85%
La bomba s'ha de parar (obrir el relay1) si el nivell del diposit inferior baixa per sota del 10% o el nivell del diposit es igual o superior al 100%
S'ha de fer un dashboard que marqui els nivells dels diposits i indiqui si la bomba esta en marxa o parada
