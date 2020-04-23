% Funckja pomocnicza do wyswietlania postepu symulacji
function  staryProcent = viewStage(staryProcent,u,ileRazy)
      nie = 0;
      procent = idivide((u/ileRazy)*100,int16(1));
      if procent == staryProcent
        nie = 1;
      end
      staryProcent = procent;
      if (procent < 100 && nie == 0)
          if u ~= 1
              fprintf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b");
              if procent < 11
                fprintf("\b");
              else 
                fprintf("\b\b");
              end
          end
          fprintf("\t %d%% of simulation completed.",procent)
      end
end


