  clear;
clc;

cps=0:10:100;

m = 6;
n = 2^m - 1;
k = 57;

BER = zeros(1,k);
Suma = zeros(1,11);

length = 1;
cp = 0;

[genpoly,t] = bchgenpoly(n,k);

for u = 1 : 11
    
    for i = 1 : 100
            
            BER = zeros(1,k);
            msg = gf(randi([0 1],length,k));
            code = bchenc(msg,n,k);

            for g = 1 : k
                val = randi([0 100],1,1);
                if val > 100 - cp
                    if code(g) == 0
                        code(g) = 1;
                    else
                        code(g) = 0;
                    end
                end
            end          

            [newmsg,err,ccode] = bchdec(code, n, k);

            errors = 0;

            test = (msg.x ~= newmsg.x);
            for j = 1:k
                errors = errors + test(j);
            end

            BER(i) = errors/k;

    end
    cp = cp + 10;
    
    for i = 1:100
        Suma(u) = Suma(u) + BER(i);
    end

%     Suma(u) = Suma(u) / 100;
    
end

subplot(1,1,1);
plot(cps,Suma);
xlabel('Przek³amanie');
ylabel('BER');



        


