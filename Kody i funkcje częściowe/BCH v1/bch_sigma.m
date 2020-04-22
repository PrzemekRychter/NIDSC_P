clear;
clc;

sigmaa=0:10:100;

m = 4;
n = 2^m - 1;
k = 11;

BER = zeros(1,k);
Suma = zeros(1,11);

len = 1;
sigma = 0;

[genpoly,t] = bchgenpoly(n,k);

for u = 1 : 11
    
    for i = 1 : 100
            
            BER = zeros(1,k);
            msg = gf(randi([0 1],1,k));
            code = bchenc(msg,n,k);                                               
            
            for g = 1 : k
                val = normrnd(0,sigma, [1 length(code)]);
                if code(g) == 1
                    val = val + 1;
                end
                if(val <= 0)
                    code(g) = 0;
                else
                    code(g) = 1;
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
    sigma = sigma + 10;
    
    for i = 1:100
        Suma(u) = Suma(u) + BER(i);
    end

%     Suma(u) = Suma(u) / 100;
    
end

subplot(1,1,1);
plot(sigmaa,Suma);
xlabel('Sigma');
ylabel('BER');



        


