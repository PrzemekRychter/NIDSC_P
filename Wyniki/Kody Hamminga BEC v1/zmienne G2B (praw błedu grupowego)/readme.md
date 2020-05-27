 Badanie BER dla kodów hamminga, dla kanału błędów grupowych <br>
 Śr długosc błedu (ABEL) = 4 (bity) <br>
 Praw. błedu grupowego: 0%  <br>
 Praw przekłamania bitu w stanie złym: 90%  <br>
 Zmienny paramter: praw.błedu grupowego od 0% do 20%  <br>
  <br>
leng = 100000;  <br>
typ = 0;  % 0 - kody hamminga  <br>

ABEL = 4;  <br>
G2B = 0.0;  <br>
loss = 0.9;  <br>
zmienny = 2;  <br>
skok = 0.0001;  (zmiana G2B z kazda iteracja) <br>
kon = 0.2; (koncowy G2B)  <br>
