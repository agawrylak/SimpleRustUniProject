## Instrukcje

Link do zahostowanego serwisu (lepsze niż screenshot!)

https://fullstack-sprawozdanie-1.fly.dev/

Do optymalizacji dockerfile wykorzystałem oficjalny guide:

https://www.docker.com/blog/simplify-your-deployments-using-the-rust-official-image/

### Budowanie obrazu kontenera

Aby zbudować obraz kontenera, wykonaj polecenie:

```shell
docker build -t nazwa_obrazu .
```
### Uruchamianie kontenera

Aby uruchomić kontener na podstawie zbudowanego obrazu, wykonaj polecenie:

```shell
docker run -p 8000:8000 nazwa_obrazu
```

### Wyświetlenie logów

Aby wyświetlić logi uruchom polecenie:

```shell
docker logs nazwa_kontenera
```

### Liczba warstw obrazu

Aby sprawdzić, ile warstw posiada zbudowany obraz, możesz użyć polecenia docker history. Wykonaj polecenie:

```shell
docker history nazwa_obrazu
```