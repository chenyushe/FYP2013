AddrData = reshape(textread('Row1.txt', '%s'),16,8);
AddrResults = reshape(textread('Row1Prec3.txt', '%s'),106,8);
string = {'DELETE'};

for r = 1:16
   for c = 1:8
        number = 0;
        SearchStr = AddrData(r,c);
        for ResultsC = 1:8
            for ResultsR = 1:106
                ResultsStr = AddrResults(ResultsR,ResultsC);
                if strcmp(SearchStr,ResultsStr)
                    if number >= 1
                        AddrResults(ResultsR,ResultsC) = string;
                    end
                    number = number +1;
                end          
            end
        end
   end
end
