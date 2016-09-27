%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title:        Pancake Sort Performance Recorder in MATLAB
% Author:       SID: 1402187
% Rev. Date:    30 Apr 2016
% Original source: http://rosettacode.org/wiki/Sorting_algorithms/Pancake_sort#MATLAB_.2F_Octave
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [V numComparisons numAccesses] = pancakeSort(V)
 
    numComparisons = 0;
    numAccesses = 0;
    
    for i = (numel(V):-1:2)
 
         
        numAccesses = numAccesses + 2;
        maxElem = V(i);
        maxIndex = i;
 
        %Find the max element in the current subset of the list
        for j = (i:-1:1)
            
            numComparisons = numComparisons +1;
            numAccesses = numAccesses +2;
            if V(j) >= maxElem
                numAccesses = numAccesses + 2;
                maxElem = V(j);
                maxIndex = j;
            end                              
        end
 
        %If the element is already in the correct position don't flip
        if i ~= maxIndex
 
            %First flip flips the max element in the stack to the top                     
            for a = 1:maxIndex
                numAccesses = numAccesses +4;
                swap = V(a);
                V(a) = V(maxIndex);
                V(maxIndex) = swap;             
            end
            
 
            %Second flip flips the max element into the correct position in
            %the stack                      
            k = i;
            b = 1;
            while b<k   
                numAccesses = numAccesses +4;
                swapb = V(b);
                V(b) = V(k);
                V(k) = swapb;
                k = k-1;
                b = b + 1;
            end
 
        end %end if  
    end %for
end %pancakeSort