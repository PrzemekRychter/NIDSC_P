Badanie BER dla kodów hamminga, dla kanału błędów grupowych
Śr długosc błedu (ABEL) = 3 (bity)
Praw. błedu grupowego: 3%
Praw przekłamania bitu w stanie złym: 90%
Zmienny paramter: Śr długosc błedu (ABEL) od 3 do 10
leng = 100000;
typ = 0; % 0 - kody hamminga

ABEL = 3-10;
G2B = 0.03;
loss = 0.9;
zmienny = 1;
skok = 0.0001; (zmiana abel z kazda iteracja)
kon = 8; (koncowy abel) 
