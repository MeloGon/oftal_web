# Configuración de Variables de Entorno

## Para Desarrollo Local

1. Copia el archivo `.env.example` a `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edita el archivo `.env` con tus valores reales:
   ```bash
   nano .env
   ```

3. Asegúrate de que el archivo `.env` esté en `.gitignore` (ya está configurado).

## Para CI/CD (GitHub Actions)

Configura las siguientes variables de entorno en tu repositorio de GitHub:

1. Ve a Settings > Secrets and variables > Actions
2. Agrega los siguientes secrets:

### Secrets Requeridos:
- `SUPABASE_URL`: Tu URL de Supabase
- `SUPABASE_ANON_KEY`: Tu clave anónima de Supabase
- `API_BASE_URL`: URL base de tu API (opcional)
- `API_TIMEOUT`: Timeout de la API en milisegundos (opcional)

### Secrets Opcionales:
- `FIREBASE_API_KEY`: Clave de API de Firebase
- `FIREBASE_AUTH_DOMAIN`: Dominio de autenticación de Firebase
- `FIREBASE_PROJECT_ID`: ID del proyecto de Firebase
- `FIREBASE_STORAGE_BUCKET`: Bucket de almacenamiento de Firebase
- `FIREBASE_MESSAGING_SENDER_ID`: ID del remitente de mensajería
- `FIREBASE_APP_ID`: ID de la aplicación de Firebase

## Estructura del Archivo .env

```env
# Supabase Configuration
URL=your_supabase_url_here
ANONKEY=your_supabase_anon_key_here

# API Configuration
API_BASE_URL=https://api.example.com
API_TIMEOUT=30000

# App Configuration
APP_NAME=Oftal Web
APP_VERSION=0.1.0
DEBUG_MODE=true
```

## Notas Importantes

- El archivo `.env` nunca debe subirse al repositorio
- El archivo `.env.example` debe mantenerse actualizado con todas las variables necesarias
- Las variables de entorno en CI/CD se crean automáticamente durante el build
- Si agregas nuevas variables, actualiza tanto `.env.example` como el workflow de GitHub Actions
