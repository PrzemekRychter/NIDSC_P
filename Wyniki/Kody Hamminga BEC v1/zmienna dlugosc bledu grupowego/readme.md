Badanie BER dla kodów hamminga, dla kanału błędów grupowych <br>
Śr długosc błedu (ABEL) = 3 (bity) <br>
Praw. błedu grupowego: 3% <br>
Praw przekłamania bitu w stanie złym: 90% <br>
Zmienny paramter: Śr długosc błedu (ABEL) od 3 do 10 <br>
leng = 1000000 = 10^6;  <br>
typ = 0; % 0 - kody hamminga <br>

ABEL = 3-10; <br>
G2B = 0.03; <br>
loss = 0.9; <br>
zmienny = 1; <br>
skok = 0.001; (zmiana abel z kazda iteracja) <br>
kon = 10; (koncowy abel) <br>
