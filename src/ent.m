clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.

%--------------------------------------------------------------------------------------------------------

%-xlsx uzantılı excel tablosu ile aynı klasöre koyun
%-Excel formatı strain - stress - boş - starin - stress - boş - strain - st
%olacak şekilde hesapları yapar en az 1 boşluk içermelidir
%-run'a basınca discreteValues.xlx isminde bir dosya oluşur
%-dosyanın içinde sırasıyla ayrık değerler vardır

%--------------------------------------------------------------------------------------------------------

dinfo = dir('*.xlsx');
[status,sheets] = xlsfinfo(dinfo.name);
if exist(fullfile(pwd, "discreteValues.xls"),"file")
    delete discreteValues.xls;
end
for l=1:length(sheets)
    entities = readtable(dinfo.name,Sheet=l).Variables;
    x = size(entities,1);
    y = size(entities,2);
    maxValues = zeros(3,1);
    maxValuesIndex = 0;
    for i=1:3:y
        maxValuesIndex = maxValuesIndex + 1;
        for j=1:x
            if(~isnan(entities(j,i)) && j==x)
                maxValues(maxValuesIndex,1) = entities(j,i);
                break;
            elseif (isnan(entities(j,i)))
                maxValues(maxValuesIndex,1) = entities(j-1,i);
                break;
            end
        end
    end
    maxValues = floor(maxValues);
    maxValuesIndex = 0;
    discreteValues = zeros(max(maxValues)+1,y+1);
    for i=1:3:y
        maxValuesIndex = maxValuesIndex + 1;
        for j=1:max(maxValues)
            if(j<=maxValues(maxValuesIndex)+1)
                for k=1:x
                    if(j==1)
                        discreteValues(j,i) = 0;
                        discreteValues(j,i+1) = 0;
                        break;
                    end
                    if(entities(k,i) >=j-1)
                        discreteValues(j,i) = j-1;
                        discreteValues(j,i+1) = ((entities(k-1,i+1) - entities(k,i+1))*(j - 1 - entities(k,i))/(entities(k-1,i) - entities(k,i))) +  entities(k,i+1);
                        break;
                    end
                end
            end
        end
    end
    for i=1:3:y
        maxValuesIndex = maxValuesIndex + 1;
        for j=1:max(maxValues)
            if(j~=1 && discreteValues(j,i) == 0 )
                discreteValues(j,i) = NaN;
                discreteValues(j,i+1) = NaN;
            end
            discreteValues(j,i+2) = NaN;
        end
    end

    for i=1:min(maxValues+1)
        sum = 0;
        count = 0;
        for j=2:3:y
            sum=sum+discreteValues(i,j);
            count = count + 1;
        end
        discreteValues(i,y+1) = (sum/count);
    end
  
    T = table(discreteValues);
    writetable(T,"discreteValues.xls",Sheet=l);
end
