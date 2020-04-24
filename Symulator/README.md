# Obsługa symulatora
### W celu uruchomienia Symulatora należy pobrać wszystkie skrypty z tego folderu.
### simulate.m - uruchomienie symulatora.

1. Wprowadź ilość bitów dla których będą przeprowadzane kodowania,transmisja,dekodowania
2. Wybierz rodzinę kodów, z chcesz zbadać konkretny kod
3. Podaj niezbędne parametry kodu.
4. Wybierz model kanału. BSC - błedy pojedyńcze, BNC - błedy grupowe
  4.a. W przypadku BNC podaj wartości parametrów
  4.b. W przypadku BNC wybierz zmienny parametr kanału.
5. Wprowadź początkową wartość zmiennego parametru kanału. 
   Dla BSC domyślnie jest to jedyny parametr - prawdopodobieństwo wystąpienia błedu
6. Wprowadź interwał(skok) z jakim parametr ma się zmieniać.
7. Wprowadź końcową wartość zmiennego parametru.

Symulacja zostanie wykonana. W celu pozyskania danych do dalszych badań,
przed uruchomieniem symulacji przypisz wyniki symulacji do zmiennej 
        dane = obiekt.simUSR();  
W zmiennej dane w 1 wierszu będzie oś X, a w 2 oś Y

W celu zapamiętania danych zapisz wykres będący wynikiem symulacji (okno.fig)
funkcja "getAllData" realizuje "wyłuskanie danych" z obiektu okno.fig

Alternatywne uruchomienie symulatora za pomocą funkcji simBSC(); oraz simBNC();
jest pokazane w skrypcie "uzycieSymulatora.m"

Uruchamianie z kanałem BNC (błedy grupowe) wymaga podania 3 parametrów: 
* ABEL - Avarage burst error length - średnia długosc błędu
* r = 1/Abel r to prawdopodobieństwo przejścia ze stanu złego do dobrego
* Probavility of burst error  - prawdopodobienstwo wystapienia blędu grupowego to poprostu przejscie G2B

ABEL definiuje q = B2G  Probavility of burst error = G2B definiuje G2B 
 * https://www.researchgate.net/publication/266652304_Subjective_and_Objective_Evaluation_and_Packet_Loss_Modeling_for_3D_Video_Transmission_over_LTE_Networks
* https://www.google.com/search?client=firefox-b-d&q=mochancki+kodowanie ( książka Władysława Mochnackiego)

Przydatne założenia: 
* Loos density - prawdopodobieństwo błedu w stanie złym - powinno być duze od 40% do 100%
* ABEL - 3 do 10 (może być większe)
* Probability of burst error - raczej małe (np 5%) - ten parametr gdy jest zmienny wykresy są intyicyjnie dobre, logiczne.
 Wybieramy z tych 3 parametrów 1 zmienny parametr nalepiej 1 albo 3. Przy zmiennnym ABEL wykresy "dziwne"
 Przy zmieniennym ABEL (rosnacym) BER powinien rosnąć ponieważ długosc błędu rosnie (prawopodobieństwo ich wystapienia stale) ale wykres jest poszarpany.
 
 
