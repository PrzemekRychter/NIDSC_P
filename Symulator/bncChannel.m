% Nasza implementacja kanału o modelu Gilberta - sumuluje błedy grupowe
function transmittedData = bncChannel(data,loss,fromG2B,fromB2G) % burst noise channel
    lossDensity = loss;                 % prawdopodobieństwo błedu w stanie złym
    fromGoodToBad = fromG2B;            % prawdopodobieństwo przejścia ze stanu dobrego do złego
    fromBadToGood = fromB2G;            % prawdopobieństwo przejścia ze stanu złego do dobrego
    transmittedData = data;
    state = 1;                          % poczatkowo stan = 1 - stan dobry
    nextBit = 1;
    while nextBit <= size(data,1)
        x = rand;
        if state == 1
            if x <= fromGoodToBad
                state = 0;
            end
        else                        % galez w stanie zlym
            if x <= lossDensity     % prawdopodobienstwo bledu w stanie zlym
                transmittedData(nextBit,1) = mod(transmittedData(nextBit,1) + 1,2); % zamiana 0 na 1, 1 na 0
            end
            y = rand;
            if y <= fromBadToGood
                state = 1;
            end    
        end
        nextBit = nextBit + 1;
    end
end




