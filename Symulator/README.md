# Obsługa symulatora
### W celu uruchomienia Symulatora należy pobrać wszystkie skrypty z tego folderu.
### simulate.m - uruchomienie symulatora.

Pomocnicze funkcje do symulatora, w tym do kodów Hamminga
takie jak encodeHamming, generateData ... , można było
umieścić w metodach symulatora, ale od początku wybrano rozwiązanie by korzytsać z funkcji.

Dla kodu Hamminga należy podać poprawne wartości n i k np.: 7 i 4, 15 i 11.
Uruchomienie symulacji dla kanału BSC przebiega bezproblemowo,
jedynie duże dane np.: 500 000 bitow i prawdopodobienstwo przeklamania od 0 do 1 z interwałem 
0.001 czyli 1000 - krotne wykonywane kodowanie i dekodowanie,
może powodować że symulacja bedzie długo trwała ( dla powyższych danych 2.5 minuty).

Uruchamianie z kanałem BNC (błedy grupowe) wymaga podania 3 parametrów: 
* ABEL - Avarage burst error length - średnia długosc błędu
* r = 1/Abel r to prawdopodobieństwo przejścia ze stanu złego do dobrego
* Probavility of burst error  - prawdopodobienstwo wystapienia blędu grupowego

 Probavility of burst error definiuje p - przejście z dobrego do złego. Opisany został troche innym wzorem niż ten który jest podany pod wskazanymi linkiami
* https://www.researchgate.net/publication/266652304_Subjective_and_Objective_Evaluation_and_Packet_Loss_Modeling_for_3D_Video_Transmission_over_LTE_Networks
* https://www.google.com/search?client=firefox-b-d&q=mochancki+kodowanie ( książka Władysława Mochnackiego)

Przydatne założenia: 
* Loos density - prawdopodobieństwo błedu w stanie złym - powinno być duze od 40% do 100%
* ABEL - od 5
* Probability of burst error - raczej małe - ten parametr gdy jest zmienny wykresy są intyicyjnie dobre, logiczne. Bliskie 1
 wybieramy z tych 3 zmienny parametr nalepiej 2 albo 3.
 Przy zmieniennym ABEL (rosnacym) BER powinien rosnąć ponieważ długosc błędu rosnie (prawopodobieństwo ich wystapienia stale) ale wykres jest poszarpany.
 
 
