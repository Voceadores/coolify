# Despliegue en Coolify

Este repo no traia Dockerfile ni Compose. Los archivos agregados empaquetan este codigo de HumHub `1.18.4-pl1` con Apache/PHP 8.2 y servicios auxiliares para MariaDB, Redis, cola y cron.

## Punto importante sobre proxies

Coolify usa Traefik como proxy publico y terminador TLS. HumHub no reemplaza eso: dentro del contenedor necesita un servidor web PHP, en este caso Apache. La cadena queda:

```text
Internet -> Traefik/Coolify HTTPS -> web:80 Apache/PHP -> HumHub
```

No publiques `ports:` en Compose y no definas redes custom. Coolify conectara Traefik a su red administrada.

## Pasos en Coolify

1. Crea una aplicacion tipo Docker Compose desde el repositorio.
2. En el campo de compose usa `docker-compose.coolify.yml`.
3. Configura el dominio en Coolify para el servicio `web`.
4. Define estas variables:

```env
MYSQL_DATABASE=humhub
MYSQL_USER=humhub
MYSQL_PASSWORD=pon-una-clave-larga
MYSQL_ROOT_PASSWORD=pon-otra-clave-larga
```

5. Despliega.
6. Abre el dominio y completa el instalador. Si pregunta por base de datos:
   - Host: `db`
   - Base de datos: el valor de `MYSQL_DATABASE`
   - Usuario: el valor de `MYSQL_USER`
   - Password: el valor de `MYSQL_PASSWORD`

## Traefik y HTTPS

HumHub debe confiar en los headers `X-Forwarded-*` que envia Traefik para detectar HTTPS. En el Compose se define:

```yaml
HUMHUB_CONFIG__COMPONENTS__REQUEST__TRUSTED_HOSTS: '["0.0.0.0/0"]'
```

Esto es practico en Docker porque no conoces de antemano la IP interna de Traefik. Si quieres endurecerlo despues, cambia ese rango por la subred Docker/Coolify real.

## Background jobs

HumHub necesita ejecutar:

```sh
php protected/yii queue/run
php protected/yii cron/run
```

Por eso el Compose crea servicios separados `queue` y `cron`. En `Administration -> Information -> Background jobs` deberias ver que se actualizan.

## Volumenes persistentes

Se persisten `uploads`, `assets`, `protected/runtime`, `protected/modules`, `themes`, `protected/config`, MariaDB y Redis. No borres esos volumenes entre redeploys.
