% Author: Author: Claire Homer, Sergey Magedov, Yash Shah, Tanner Thornton, Alyssa Wilson-Baxter
% Description: Elephant class which has the properties of reproduce, naturaldeath, id, gender, dueYear,
% isPregannt, etc. This object of this class represents an individual elephant


classdef Elephant
    properties
        id = 0;
        birthYear = 0;
        currentYear = 0;
        gender = 'F';
        darted = false;
        dartedYear = 0;
        isPregnant = false;
        courtshipTime = false;
        dueYear = 0;
        childID = int16.empty(0,1);
    end
    methods
        % constructor of the class 
        % Sets the birthyear and current year
        function obj = Elephant(ID, year, gender)
            obj.id = ID;
            obj.birthYear = year;
            obj.currentYear = year;
            obj.gender = gender;
            obj.darted = false;
            obj.dartedYear = 0;
            obj.isPregnant = false;
            obj.courtshipTime = false;
            obj.dueYear = 0;
            obj.childID = int16.empty(0,1);

        end
        % gets the age using the passed year
        function age = getAge(obj, year)
            age = year - obj.birthYear;
        end
        % elephants can reproduce when their age is between 10-60; female and is not pregnant or in courtship time. 
        % it must also be check whether the elephant was darted or not 
        function a = canReproduce(obj)
            age = getAge(obj, obj.currentYear);
            if ((age > 10) && (obj.gender == 'F') && (age < 60))
                if ((obj.isPregnant == false) && (obj.courtshipTime == false))
                    if (obj.darted == false)
                        a = true;
                    else
                        a = false;
                    end
                else 
                    a = false;
                end
            else
                a = false;
            end 
        end
        % elephants reproduces every year
        function [obj, a] = reproduce(obj)
            if (canReproduce(obj) == true)
                obj.isPregnant = true;
               obj.dueYear = obj.currentYear + 4;
               obj.courtshipTime = true;
               a = true;
            else 
                a = false;
            end
            
        end
        % whether elephant is still pregnant?
        function obj = stillPregnant(obj)
            left = obj.dueYear - obj.currentYear;
            
            if (left == 2)
                obj.isPregnant = false;
            end
            
            if (left == 0)
                obj.courtshipTime = false;
                obj.isPregnant = false;
                obj.dueYear = 0;
            end
        end
        % sets the current year
        function obj = setcurrentYear(obj, year)
            obj.currentYear = year;
        end
        % whether this elephant can be darted
        % the darting is determined if the elephant's age is between 10-60 and the gender is female.
        function a = canDart(obj)
            age = getAge(obj, obj.currentYear);
            if ((age > 10) && (obj.gender == 'F') && (obj.darted == false))
                a = true;
            else 
                a = false;
            end
        end
        % darts the elephant 
        function [obj, a] = Dart(obj, year)
            b = canDart(obj);
            if (b == true)
                obj.darted = true;
                obj.dartedYear = year;
                a = true;
            else
                a = false;
            end
        end
        % check darted year every year. sets the flags accordingly
        function obj = checkDartedYear(obj)
            if ((obj.darted == true) && (obj.currentYear - obj.dartedYear == 2))
                % fprintf("ID: %d and darted is over \n", obj.id);
                obj.darted = false;
                obj.dartedYear = 0;
            end
        end
        % check this every year
        % i.e. whether the elephant is still pregnant
        % how long is left in darting expiry
        function obj = checkEveryYear(obj, year)
            obj = setcurrentYear(obj, year);
            obj = checkDartedYear(obj);
            if ((obj.isPregnant == true) || (obj.courtshipTime == true))
                obj = stillPregnant(obj);
            end
        end
        % The natural death occurs if the age is > 70
        function a = naturalDeath(obj)
            age = getAge(obj, obj.currentYear);

            if (age > 70)
                a =  true;
            else
                a = false;
            end

        end
        % return the flag whether elephant is darted or not
        function a = isDarted(obj)
            a = obj.darted;
        end
        % return the gender
        function a = getGender(obj)
            a = obj.gender;
        end
        % return the flag whether elephant is pregnant or not 
        function a = checkPregnant(obj)
            a = obj.isPregnant;
        end
    end
end
