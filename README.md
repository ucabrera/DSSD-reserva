# Desarrollo de Software en Sistemas Distribuidos 2022 - Entrega 3

## Grupo 6: 

- Rucci, Milagros
- Romoli, Nahuel
- Cabrera, Ulises

## Documentación
Documentación específica de reserva de materiales: https://github.com/ucabrera/DSSD-reserva/tree/main/reserva-material

Documentación específica de reserva de espacios de fabricación: https://github.com/ucabrera/DSSD-reserva/tree/main/reserva-espacio

### Un poco de JWT
Se utiliza como algoritmo H256. Los tokens expiran pasados 1600 segundos.
Se utilizan variables de ambiente para el issuer y para el secret.

Muestran error si:
 - el token expiró
 - no se envian credenciales correctas
 - el token es alterado de alguna manera.
