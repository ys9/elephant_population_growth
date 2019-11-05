%
% Author: Author: Claire Homer, Sergey Magedov, Yash Shah, Tanner Thornton, Alyssa Wilson-Baxter
% Description: It provides the Data Structure to the Class Elephants. It
% sets the current year to all the elephants every year. This is an
% iterative model which iterates over the number of years. 
% This class also takes care of darting. The Darting is done
% probabilistically, and it uses the cumulative distribution function of
% logistic distribution to find out the probability of the darting. 



classdef ElephantControl
        properties
                Elephants = containers.Map('KeyType', 'uint32', 'ValueType', 'Any');
                id = 1;
                currentYear = 0;
                countDartedElephants = 0;
                probDarting = 0;
                relocatingElephants = false;
                ContraceptionKillsFetus = true;
                rv = makedist('Logistic', 'mu', 11000, 'sigma', 200)
                transported = zeros(71, 1);
                survivalRates = zeros(71, 1);
        end

        methods
                function obj = ElephantControl(year, relocatingElephants, ContraceptionKillsFetus)
                        obj.Elephants = containers.Map('KeyType', 'uint32', 'ValueType', 'Any');
                        obj.id = 1;
                        obj.currentYear = year;
                        obj.countDartedElephants = 0;
                        obj.probDarting = 0;                      
                        obj.relocatingElephants = relocatingElephants;
                        obj.ContraceptionKillsFetus = ContraceptionKillsFetus;
                        % For population of 11000
                        obj.rv = makedist('Logistic', 'mu', 11000, 'sigma', 200);  
                        % For population of 300
                        %obj.rv = makedist('Logistic', 'mu', 300, 'sigma', (300/11000) * 200);
                        % For population of 25000
                        % obj.rv = makedist('Logistic', 'mu', 25000, 'sigma', (25000/ 11000) * 200);
                end

                function obj = Death(obj)
                    % The survival rate for infants is 70-80%
                        prob1 = 0.05; 
                        pmf1 = [prob1, (1-prob1)];
                    % The survival rate for adults is > 95%
                        prob2 = 0.25;
                        pmf2 = [prob2, (1 - prob2)];
                        population = 0:1;
                        sample_size = length(obj.Elephants);
                        Adults_prob = randsample(population, sample_size, true, pmf1);
                        infants_prob = randsample(population, sample_size, true, pmf2);
                        copy = obj.Elephants;
                        count = 1;
                        for k =cell2mat(keys(copy))
                                if (isKey(obj.Elephants, k) == false)
                                        continue;
                                end
                                i = copy(k);
                                if (naturalDeath(i) == true)
                                        remove(obj.Elephants, k);
                                        count = count + 1;
                                        continue;
                                elseif (getAge(i, obj.currentYear) >= 1)
                                        if (Adults_prob(count) == 0)
                                                if (i.isPregnant == false)
                                                    % if female is not pregnant
                                                    % then, the she dies
                                                        remove(obj.Elephants, k);
                                                        count = count + 1;
                                                        continue;
                                                else
                                                    % if the female is
                                                    % pregnant, then the
                                                    % fetus also dies with
                                                    % her
                                                        for m = i.childID
                                                                if (isKey(obj.Elephants, m) == false)
                                                                    continue;
                                                                end
                                                                l = obj.Elephants(m);
                                                                if (l.getAge(obj.currentYear) < 0)
                                                                    remove(obj.Elephants, m);
                                                                end
                                                        end
                                                        remove(obj.Elephants, k);
                                                        count = count + 1;
                                                        continue;
                                                end
                                        end
                                elseif (getAge(i, obj.currentYear) == 0)
                                    % the infant's death
                                        if (infants_prob(count) == 0)
                                                remove(obj.Elephants, k);
                                                count = count + 1;
                                                continue;
                                        end
                                else 
                                        count = count + 1;
                                        continue;
                                end
                                count = count + 1;
                        end
                end
                % Sets the current year for all the elephants and performs
                % the birth, death, and reproduction 
                function obj = setCurrentYear(obj, year)
                        obj.currentYear = year;
                        obj = calculateDartingProb(obj);
                        copy = obj.Elephants;
                        obj = dart(obj);
                        twinchildren_prob = randsample([0,1], length(obj.Elephants), true, [(1-0.0135), 0.0135]);
                        count = 1;
                        for k = cell2mat(keys(copy))
                                i = copy(k);
                                i = checkEveryYear(i, obj.currentYear);
                                % Every female between 10-60 and who are
                                % not pregnant and who are not going
                                % through the courtship time will have a
                                % chance to reproduce. That's the condition
                                % that it is checking for
                                % If the cow is darted, then she can't
                                % reproduce for 2 years. 
                                [i, newBaby] = reproduce(i);
                                
                                if (newBaby == true)
                                        if ((twinchildren_prob(count) == 0))
                                           
                                                gen = randsample(['F', 'M'], 1, true, [0.5, 0.5]);
                                                obj = create(obj, obj.currentYear + 2, gen);
                                                i.childID = [i.childID, obj.id];
                                        else
                                        % twin children probability is
                                        % 1.35% and if that is true,this is
                                        % not for twin probability
                                                for t = 1:2
                                                        gen = randsample(['F', 'M'], 1, true, [0.5, 0.5]);
                                                        obj = create(obj, obj.currentYear + 2, gen);
                                                        i.childID = [i.childID, obj.id];
                                                end
                                        end
                                end
                                obj.Elephants(k) = i;
                                count = count + 1;
                        end
                        
                        obj = Death(obj);
                        if (obj.relocatingElephants == true)
                            % This only occurs when relocation is true.
                            % Relocation is not dependent upon current
                            % population
                            obj = generateTransportMatrix(obj);
                            obj = transportElephants(obj);
                        end

                end
                % Creates Elephants and stores them into a Data Structure
                function obj = create(obj, year, gender)
                        obj.id = obj.id + 1;
                        e = Elephant(obj.id, year, gender);
                        obj.Elephants(obj.id) = e;
                end
                % Creates size number of elephants
                function obj = createElephants(obj, size)
                        r = randsample(['M', 'F'], size, true, [0.5, 0.5]);

                        for i = 1:size
                                obj = create(obj, obj.currentYear, r(i));
                        end

                end
                % Creates size number of elephants with year as a birthyear
                function obj = createElephantsSizeYear(obj, size, year)
                        r = randsample(['M', 'F'], size, true, [0.5, 0.5]);

                        for i = 1: size
                                obj = create(obj, year, r(i));
                        end
                end
                % darts elephants probabilistically
                function obj = dart(obj)

                        prob = obj.probDarting;
                        copy = obj.Elephants;
                        r = randsample([0,1], length(obj.Elephants), true, [(1-prob), prob]);
                        count = 1;
                        for k = cell2mat(keys(copy))
                                if (isKey(obj.Elephants, k) == false)
                                        continue;
                                end
                                i = copy(k);
                                if (r(count) == 1)
                                        [i, a] = Dart(i, obj.currentYear);
                                        if (a == true)
                                               if (obj.ContraceptionKillsFetus == true)
                                                    [obj, i] = checkChildren(obj, i);
                                               end
                                        end
                                end
                                obj.Elephants(k) = i;
                                count = count + 1;
                        end
                end
                % The function to remove children of the parent if their age is < 0
                function [obj, i] = checkChildren(obj, i)
                        copy = i.childID;

                        for j = copy
                                tmp = ismember(i.childID, j);
                                if (sum(tmp) == false)
                                        continue;
                                end
                               
                                if (~isKey(obj.Elephants, j) && (sum(tmp) == 1))
                                        index = 1;
                                        for l = tmp
                                                if (l == true)
                                                        break;
                                                end
                                                index = index + 1;
                                        end
                                        i.childID(index) = [];
                                        continue;
                                end
                                if (isKey(obj.Elephants, j) == 0)
                                    continue;
                                end
                                if ( getAge(obj.Elephants(j), obj.currentYear) < 0)
                                        i.childID = i.childID(i.childID ~= j);
                                        remove(obj.Elephants, j);
                                end
                        end
                end
                % function to calculate darting probability using the cdf of the logistic distribution
                % the probability = cdf(mu=11000, s = 200)
                function obj = calculateDartingProb(obj)

                        [f, m] = countByGender(obj);
                        obj.probDarting = obj.rv.cdf(f+m);

                end

                % Counts the number of elephants which are darted
                function n = countDarted(obj)
                        obj.countDartedElephants = 0;
                        for k = cell2mat(keys(obj.Elephants))
                                i = obj.Elephants(k);
                                if (isDarted(i) == true)
                                        obj.countDartedElephants = obj.countDartedElephants + 1;
                                end
                        end
                        n = obj.countDartedElephants;
                end
                % Counts the number of elephants by gender
                function [f,m] = countByGender(obj)
                        femaleCounts = 0;
                        maleCounts = 0;

                        for k = cell2mat(keys(obj.Elephants))
                                i = obj.Elephants(k);

                                if (getGender(i) == 'F')
                                        femaleCounts = femaleCounts + 1;
                                else
                                        maleCounts = maleCounts + 1;
                                end
                        end
                        f = femaleCounts;
                        m = maleCounts;
                end 
                % Prints summary
                function printSummary(ec)
                        fprintf("Number of elephants (Pregnant elephants are counted as 2): %d \n", length(ec.Elephants));
                        fprintf("Count Darts %d, given the probability of being darted %f \n", countDarted(ec), ec.probDarting);
                        fprintf("current year: %d \n", ec.currentYear);
                        fprintf("Pregnant Elephants: %d \n", countPregnant(ec));
                        [f, m] = countByGender(ec);
                        fprintf("female counts, male counts = %d, %d \n", f, m);
                        fprintf("\n\n\n");

                end
                % Counts the number of pregnant elephants
                function n = countPregnant(obj)
                        count = 0;
                        for k = cell2mat(keys(obj.Elephants))
                                i = obj.Elephants(k);

                                if (getGender(i) == 'F')
                                        if (checkPregnant(i))
                                                count = count + 1;
                                        end 
                                end
                        end
                        n = count;
                end
                % age structure of the elephant population. ages range between 0-70                       
                function aS = update_age_structured(obj)        
                        age_structured = zeros(1, 71);
                        for i = cell2mat(keys(obj.Elephants))
                            e = obj.Elephants(i);
                            age = e.getAge(obj.currentYear);
                            if (age >= 0 && age <= 70)
                                age_structured(age + 1) = age_structured(age + 1) + 1;
                            end
                        end            
                        aS = age_structured;
                end
                %% Enable this only when transportation is enabled
                function obj = generateTransportMatrix(obj)
                        obj.transported = round(randfixedsum(71, 1, round(200 * rand(1) + 600), 1, 30));
                end

                function ec = transportElephants(ec)
                    copy = ec.Elephants;
                    
                    for k = cell2mat(keys(copy))
                        % Check whether key belongs to original map
                        if (isKey(ec.Elephants, k) == false)
                                continue;
                        end 
                        % check whether age > 0
                        i = copy(k);
                        age = i.getAge(ec.currentYear);

                        if (age < 0)
                                continue;
                        end
                        
                        % Check that there are still need to transport from
                        % this age, then transport, otherwise continue
                        if (ec.transported(age + 1) > 0)
                            if (i.isPregnant == false)
                                % Can't transport Females who are pregnant
                                remove(ec.Elephants, k);
                                ec.transported(age + 1) = ec.transported(age + 1) - 1;
                            end
                        end    
                    end
                end
                    
                        


        end

        
end