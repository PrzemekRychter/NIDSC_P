% Badanie BER dla kodów hamminga, dla kanału błędów grupowych
% Śr długosc błedu (ABEL) = 4
% Praw. błedu grupowego: 0%
% Praw przekłamania bitu w stanie złym: 90%
% Zmienny paramter: praw.błedu grupowego od 0% do 10%

leng = 100000;
typ = 0;  % 0 - kody hamminga
n = 15;
k = 5;
ABEL = 4;
G2B = 0.0;
loss = 0.9;
zmienny = 2;
int = 0.00001;
kon = 0.1;
a = Symulator();

%a.simBNC(leng,typ,n,k,ABEL,G2B,loss,zmienny,int,kon);

sym1 = a.simBNC(leng,typ,3,1,ABEL,G2B,loss,zmienny,int,kon);
sym2 = a.simBNC(leng,typ,7,4,ABEL,G2B,loss,zmienny,int,kon);
sym3 = a.simBNC(leng,typ,15,11,ABEL,G2B,loss,zmienny,int,kon);
sym4 = a.simBNC(leng,typ,31,26,ABEL,G2B,loss,zmienny,int,kon);
sym5  = a.simBNC(leng,typ,63,57,ABEL,G2B,loss,zmienny,int,kon);
sym6 = a.simBNC(leng,typ,127,120,ABEL,G2B,loss,zmienny,int,kon);
sym7 = a.simBNC(leng,typ,255,247,ABEL,G2B,loss,zmienny,int,kon);

figure(50);
hold on;
plot(sym1(1,:),sym1(2,:));
plot(sym2(1,:),sym2(2,:));
plot(sym3(1,:),sym3(2,:));
plot(sym4(1,:),sym4(2,:));
plot(sym5(1,:),sym5(2,:));
plot(sym6(1,:),sym6(2,:));
plot(sym7(1,:),sym7(2,:));


