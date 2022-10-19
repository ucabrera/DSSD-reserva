# Desarrollo de Software en Sistemas Distribuidos 2022 - Entrega 3

## Grupo 6: 

- Rucci, Milagros
- Romoli, Nahuel
- Cabrera, Ulises

# Reserva de espacios de fabrición

## URL en fly.io: https://reserva-espacio.fly.dev

### Endpoints: 

**POST /login** - Genera el token, espera 2 parámetros: username y password.

Hay definido un solo usuario:

- username: wwglasses
- password: wwglasses


### Ejemplo de uso:
https://reserva-espacio.fly.dev/login?username=wwglasses&password=wwglasses

![Uso de /login](./capturas//captura-token?raw=true)

**POST /api/search** - Retorna la lista de proveedores de espacios de fabricación. Necesita el token en un header Authorization, 2 paramétros obligatorios y 1 opcional.

**Parámetros:**

Obligatorios:
- fecha(date): fecha en la cual se desea empezar a utilizar el espacio. Debe ser mayor al día de la fecha.
- dias(integer): cantidad de día que se desea reservar el espacio. Debe ser mayor a 0.

Opcional:
- caso(integer): Si el valor es 1, retorna al menos un espacio para la fecha solicitada en el parámetro fecha. Caso contrario la fecha es random, a futuro. 

### Ejemplos de uso:
https://reserva-espacio.fly.dev/api/search?fecha=30-11-2022&dias=30caso=1

![Uso de /api/search con caso](./capturas/captura-con-caso?raw=true)

https://reserva-espacio.fly.dev/api/search?fecha=30-11-2022&dias=30

![Uso de /api/search sin caso](./capturas/captura-sin-caso?raw=true)

**POST /api/reserve** - Simula la reserva un espacio de fabricación. Necesita el token en un header Authorization y 1 paramétro obligatorio.

**Parámetros:**

- id(integer): Debe ser mayor a 0.

### Ejemplos de uso:
https://reserva-espacio.fly.dev/api/reserve?id=47587

![Uso de /api/reserve](./capturas/captura-reserve?raw=true)

**POST /api/cancel** - Simula la cancelación de una reserva de espacio. Necesita el token en un header Authorization y 1 paramétro obligatorio.

**Parámetros:**

- id(integer): Debe ser mayor a 0.

### Ejemplos de uso:
https://reserva-espacio.fly.dev/api/cancel?id=47587
![Uso de /api/cancel](./capturas/captura-cancel?raw=true)
