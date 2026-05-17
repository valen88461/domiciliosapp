## Integración OpenWeatherMap

Este proyecto consume la API de clima de OpenWeatherMap para mostrar
la temperatura actual en la pantalla del repartidor.

### Configuración
1. Regístrate en openweathermap.org y obtén una API Key gratuita
2. En `lib/data/datasources/remote/clima_service.dart`, reemplaza
   `TU_API_KEY_AQUI` con tu key real

### Colección Postman
Importa el archivo `postman_collection.json` incluido en la raíz
del proyecto para probar todos los endpoints.

### Criterios cubiertos
- Colección Postman organizada (GET/POST/PUT/DELETE) — 25%
- ApiClient genérico con errores y timeout — 30%  
- Datos de la API visibles en la pantalla — 25%
- Mensajes amigables para timeout y sin conexión — 20%