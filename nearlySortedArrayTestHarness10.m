%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title:            Nearly Sorted (10% salt) Array - Algorithm Performance Test
% Author:           SID: 1402184
% Original author:  Ian van der Linde
% Rev. Date:        03 May 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;

maxArrayLength                = 3000;
numRepeats                    = 10;

saltationFrequency           = 10; %every n-th element sets to be random

for currentArrayLength = 2:maxArrayLength   
    
    %Bubble sort values
    bubbleSort_c_acc(1:numRepeats)       = 0;
    bubbleSort_m_acc(1:numRepeats)       = 0;
    bubbleSort_t_acc(1:numRepeats)       = 0;
    
    %Pancake sort values
    
    pencakeSort_c_acc(1:numRepeats)       = 0;
    pencakeSort_m_acc(1:numRepeats)       = 0;
    pencakeSort_t_acc(1:numRepeats)       = 0;
    
    %Oscillation sort values
    oscillationSort_c_acc(1:numRepeats)       = 0;
    oscillationSort_m_acc(1:numRepeats)       = 0;
    oscillationSort_t_acc(1:numRepeats)       = 0;
    
    
    for currentRepeat = 1:numRepeats
        
        %Using the same array for all the three algorithms
        startpos              = randi(10000,1,1)+1; 
        salterArray           = randi(10000,1,currentArrayLength);
        preorderedArray       = (startpos:(startpos+currentArrayLength)-1);
        testArray             = preorderedArray;
        
        %Salting the test array
        mysalter = saltationFrequency;
        while mysalter < length(testArray)            
            testArray(mysalter) = salterArray(mysalter);  
            mysalter = mysalter + saltationFrequency;
        end        
       
        
        %Execute bubble sorting
        [v, c, m]             = bubbleSort(testArray); % To Prime Cache Memory
        tic;
        [v, c, m]             = bubbleSort(testArray);  
        bubbleSort_t_acc(currentRepeat)  = toc;
        bubbleSort_c_acc(currentRepeat)  = c;
        bubbleSort_m_acc(currentRepeat)  = m;
        
        %Execute pancake sorting
        [v, c, m]             = pancakeSort(testArray); % To Prime Cache Memory
        tic;
        [v, c, m]             = pancakeSort(testArray);  
        pancakeSort_t_acc(currentRepeat)  = toc;
        pancakeSort_c_acc(currentRepeat)  = c;
        pancakeSort_m_acc(currentRepeat)  = m;    
        
        %Execute oscillation sorting
        [v, c, m]             = oscillatingSort(testArray); % To Prime Cache Memory
        tic;
        [v, c, m]             = oscillatingSort(testArray);  
        oscillationSort_t_acc(currentRepeat)  = toc;
        oscillationSort_c_acc(currentRepeat)  = c;
        oscillationSort_m_acc(currentRepeat)  = m;    
        
    end
   
    %Bubble sort result means and std devs
    bubbleSort_elapsedTime_mean(currentArrayLength) = mean(bubbleSort_t_acc);
    bubbleSort_elapsedTime_SD(currentArrayLength)   = std(bubbleSort_t_acc);
    
    bubbleSort_comparisons_mean(currentArrayLength) = mean(bubbleSort_c_acc);
    bubbleSort_comparisons_SD(currentArrayLength)   = std(bubbleSort_c_acc);
    
    bubbleSort_memAccess_mean(currentArrayLength)   = mean(bubbleSort_m_acc);
    bubbleSort_memAccess_SD(currentArrayLength)     = std(bubbleSort_m_acc);
    
    %Pancake sort result means and std devs
    pancakeSort_elapsedTime_mean(currentArrayLength) = mean(pancakeSort_t_acc);
    pancakeSort_elapsedTime_SD(currentArrayLength)   = std(pancakeSort_t_acc);
    
    pancakeSort_comparisons_mean(currentArrayLength) = mean(pancakeSort_c_acc);
    pancakeSort_comparisons_SD(currentArrayLength)   = std(pancakeSort_c_acc);
    
    pancakeSort_memAccess_mean(currentArrayLength)   = mean(pancakeSort_m_acc);
    pancakeSort_memAccess_SD(currentArrayLength)     = std(pancakeSort_m_acc);
    
    %Oscillation sort result means and std devs
    oscillationSort_elapsedTime_mean(currentArrayLength) = mean(oscillationSort_t_acc);
    oscillationSort_elapsedTime_SD(currentArrayLength)   = std(oscillationSort_t_acc);
    
    oscillationSort_comparisons_mean(currentArrayLength) = mean(oscillationSort_c_acc);
    oscillationSort_comparisons_SD(currentArrayLength)   = std(oscillationSort_c_acc);
    
    oscillationSort_memAccess_mean(currentArrayLength)   = mean(oscillationSort_m_acc);
    oscillationSort_memAccess_SD(currentArrayLength)     = std(oscillationSort_m_acc);
    
     
    disp(strcat('NSATH10 Completed: ', num2str((currentArrayLength / maxArrayLength)*100),' %'))
    
end

save('nearlysortedresult10.mat');