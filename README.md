# pymongo-api

## Схема:

![img.png](img.png)

Общая ссылка на реализацию всех заданий в drawio:
https://drive.google.com/file/d/1-CeA4IoThnnaEAapctkDeGUhuqF4WrZj/view?usp=sharing

Каждое задание (1-6) пронумеровано во вкладке снизу

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными

```shell
./scripts/mongo-init.sh
```

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs