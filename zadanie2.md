# Zadanie 2

Link do
aplikacji: [http://ag-zad2-env.eba-ermbpnpf.eu-central-1.elasticbeanstalk.com/](http://ag-zad2-env.eba-ermbpnpf.eu-central-1.elasticbeanstalk.com/)

## Deploy na AWS

Do deployu na AWS wykorzystałem Terraform, żeby nie musieć samemu klikać. Jako inżynier zawsze jeśli mam wybór zrobić
coś ręcznie w 10 minut, albo zautomatyzować w 8 godzin, to wiem, że wybór jest prosty :D.

## Workflow

Workflow podzieliłem na 2 joby:

### build.yml

Służy do zbudowania aplikacji i wrzucenia obrazu na Docker Hub.

1. **Checkout Repository:** Pobiera kod źródłowy repozytorium przy użyciu akcji `actions/checkout@v2`.
2. **Login to Docker Hub:** Loguje się do Docker Hub przy użyciu akcji `docker/login-action@v2`. Dane uwierzytelniające
   są pobierane z tajemnic repozytorium.
3. **Set up QEMU:** Konfiguruje QEMU dla wsparcia budowy obrazów wieloplatformowych przy użyciu
   akcji `docker/setup-qemu-action@v2`.
4. **Set up Docker Buildx:** Konfiguruje Docker Buildx dla wsparcia budowy obrazów wieloplatformowych przy użyciu
   akcji `docker/setup-buildx-action@v2`.
5. **Cache Docker layers:** Wykorzystuje mechanizm cachowania, aby przyspieszyć proces budowania obrazów. Warstwy Docker
   są przechowywane w cache i przywracane przy kolejnych budowach, co zmniejsza czas wykonania. Akcja `actions/cache@v2`
   jest używana do zarządzania cachem.
6. **Build and Push Docker Images:** Buduje obrazy Docker na podstawie pliku Dockerfile w bieżącym kontekście.
   Wykorzystywane są różne platformy (linux/amd64, linux/arm64). Następnie obrazy są wysyłane do Docker Hub.

Używanie wielu warstw i mechanizmu cache okazało się strzałem w dziesiątkę. Pierwszy build trwał 1h04min (Rust to nie
był dobry wybór). Następne? Około 5 minut - prawie 13 razy krócej. Najdłużej trwało kompilowanie każdej dependency i to
jeszcze oddzielnie dla każdej z platform.

### deploy.yml

Podzieliłem go na dwa joby - pierwszy tworzy infrastrukturę, drugi dokonuje deployu obrazu. Deploy wykonuje się tylko w
przypadku sukcesu builda.

##### Terraform

1. **Configure AWS credentials:** Ustawiam AWSowe credsy z sekretów github.
2. **Checkout Repository:** Pobiera kod źródłowy repozytorium przy użyciu akcji `actions/checkout@v2`.
3. **Change directory to Terraform package:** Wchodzę w folder zawierający pliki Terraform, żeby nie zaśmiecały głównego
   katalogu.
4. **Initialize Terraform:** Inicjalizuje projekt terraformowy.
5. **Apply Terraform:** Wykonuje potrzebne zmiany w infrastrukturze. `-auto-approve` jest potrzebne, bo normalnie
   komenda prosi o wpisanie "yes", czego oczywiście nie mogę zrobić w normalny sposób.

##### Deploy

1. **Checkout Repository:** Pobiera kod źródłowy repozytorium przy użyciu akcji `actions/checkout@v2`.
2. **Configure AWS credentials:** Ustawiam AWSowe credsy z sekretów github.
3. **Upload Dockerrun.aws.json to S3:** Wrzucam `Dockerrun.aws.json` na S3. Z jakiegoś powodu nie da się go przekazać
   bezpośrednio.
4. **Deploy to Elastic Beanstalk:** Za pomocą AWS CLI wrzucam obraz z Docker Hub na Elastic Beanstalk.
5. **Update environment:** Odświeżam środowisko tak jak w dokumentacji nakazano.

## Informacje o Terraformie

- S3 jest potrzebne, aby wrzucić plik `Dockerrun.aws.json`. Na podstawie tego pliku można zrobić deploy z gotowego
  obrazu. Wszystkie gotowe akcje obsługują tylko ponowne budowanie, więc musiałem posłużyć się tragicznej jakości
  dokumentacją AWS oraz chińskimi blogami. Walka była długa i zacięta, co można zauważyć po historii commitów.
- Sekret do API pobieram z Secret Managera i wrzucam do zmiennych środowiskowych. Próbowałem skorzystać z sekretów
  Docker, ale nie chciały ze mną współpracować, a w internecie widziałem też sporo głosów, że nie są najlepszym
  rozwiązaniem.
- Ustawienia w Beanstalku służą do ustawienia zmiennych środowiskowych - odpalam sobie logowanie oraz przekazuję klucz
  API.
- Rozwiązanie jest w pełni automatyczne i w bardzo łatwy sposób mogę teraz zrobić deploy na dowolną liczbę środowisk.

## Napotkane problemy

Generalnie największym problemem okazało się to, że domyślnie przy tworzeniu "z palca" Beanstalka tworzy się też
odpowiednia rola. Niestety w przypadku Terraform nie występuje żaden czytelny error, trzeba się domyślić przy pomocy
stackoverflow, że trzeba zrobić ją samemu oraz znaleźć wszystkie potrzebne permissiony.

#### BONUS (mój ulubiony żart informatyczny)

> Jak nazywają się najlepsi przyjaciele programisty?
>
> **devoPSY**.
