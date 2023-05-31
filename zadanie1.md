## Instrukcje

Link do zahostowanego serwisu (lepsze niż screenshot!)

https://fullstack-sprawozdanie-1.fly.dev/

Do optymalizacji dockerfile wykorzystałem oficjalny guide:

https://www.docker.com/blog/simplify-your-deployments-using-the-rust-official-image/

Głównie chodzi tu o zastosowanie cargo chef aby móc trzymać cache z budowanych dependencies (cargo nie lubi sie z dockerem).

Było sporo problemów z łączeniem się z API - reqwest wykrzaczał się na certyfikacie (dodałem krok w dockerfile),
a potem psuł się DNS. Zmieniłem też obraz na trochę "grubszy", bo brakowało sporo potrzebnych rzeczy (oczywiście errory były kompletnie nieczytelne i nie wskazywały na ten problem, ani nie mówiły czego brakuje. Dziękuje stackoverflow!).
Fix znalazłem na chińskim blogu (mam nadzieje, że to ujmie Pana za serce i duszę).
Trzeba było zmienić opcję (feature flag) w Reqwest albo dodać bibliotekę do obrazu linuxowego. Aby skrócić budowanie i wielkość obrazu
wybrałem tą pierwszą opcję. W skrócie w ubogim obrazie linuxowym nie ma supportu dla getaddrinfo.

Link do chińskiego bloga, który nakierował na fix:

https://devpress.csdn.net/cloudnative/6304d68f7e6682346619cdaf.html

Fix z Dockerfile:
```
# Install ca-certificates package
RUN apt-get update && apt-get install -y ca-certificates

# Update the CA certificates
RUN update-ca-certificates
```
Fix z Cargo.toml
```
reqwest = {version = "0.11.18", features = ["trust-dns"] }
```

### Budowanie obrazu kontenera

Aby zbudować obraz kontenera, wykonaj polecenie
(oczywiście zmienne nazwa_kontenera i nazwa_obrazu należy podmienić):

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

