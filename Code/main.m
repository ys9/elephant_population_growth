% 
% Author: Claire Homer, Sergey Magedov, Yash Shah, Tanner Thornton, Alyssa Wilson-Baxter
% File Description: This is 


clear;
clc;
format longEng;

import_proj2data;
year = 100;


%parameters
iter = 100;
ContraceptionKillsFetus = true;
RelocatingPopulation = false;

% Code begins
ec = ElephantControl(100, RelocatingPopulation ,ContraceptionKillsFetus);

rng(14532);
for i = 1:70
        % Population of 300
        %ec = createElephantsSizeYear(ec, 0.1(TotalNumber(i) +  TotalNumber1(i)), 100 - Age(i));
        % Population of 11000
        ec = createElephantsSizeYear(ec, 4 * (TotalNumber(i) + TotalNumber1(i)), 100 - Age(i));
        % Population of 25000
        %ec =  createElephantsSizeYear(ec, 5 * (TotalNumber(i) + TotalNumber1(i)), 100 - Age(i));
end
printSummary(ec);
countOfElephants = zeros(1, iter + 1);
aS = zeros(71, iter+1);
cD = zeros(1, iter + 1);
count = 1;
for y = 100:(100 + iter)
        ec = setCurrentYear(ec, y);
        countOfElephants(1, count) = length(ec.Elephants);
        printSummary(ec);
        cD(1, count) = ec.countDartedElephants();
        aS(:, y - 99) = transpose(ec.update_age_structured());
        count = count + 1;
end


plot(100:(100+iter), countOfElephants)

