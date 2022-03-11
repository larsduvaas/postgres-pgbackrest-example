

## Build postgres image

```
cd postgres-img
docker build docker --tag postgresql-img:latest

```

## start postgres server
```shell
./postgresql-img/test_skript/startLokaltPrimary.sh
```

##  Build pgbackrest-repository image
```
cd pgbackrest-repository
docker build docker --tag pgbackrest-repository:latest

```

## start pgbackrest-repository
```
./pgbackrest-repository/test_skript/startLokaltPrimary.sh
```

## run backup to repository
```
docker exec pgbackrest-repository sudo -u pgbackrest pgbackrest --stanza=my-stanza backup
```

## start standby 
Standby will use backup first, then stream from primary
```shell
./postgresql-img/test_skript/startLokaltStandby.sh
```




