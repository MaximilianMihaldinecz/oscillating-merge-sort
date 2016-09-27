%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title:        Oscillating (Merge) Sort Performance Recorder in MATLAB
% Author:       SID: 1402187
% Rev. Date:    30 Apr 2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [V numComparisons numAccesses] = oscillatingSort(V)
  
  numComparisons    = 0;
  numAccesses     = 0;
  
  %V will be filled up with this to have (N-1)^X values. Therefore can be
  %merged fully. These will be removed at the end.
  MAGICNUMBER =  intmin('int16'); 
  hasMagicUsed = false;
  
  SAFETOSTACK = 7; %Limits to (N-1)^7 maximum  sequence length.
                   %This implementation unable to guarantee consistency of
                   %sequence stacks above (N-1)^7 sequence lengths. 
                   %(consistency: stacked sequences have descending length)
                   
  inputLength = numel(V);  
  N = 0;
  SetNumberOfTapesAndMagicNumbers; %This will set N (number of tapes). Min 4.
  
  SSSPLength = ceil(log(inputLength)/log(N))+1; %Top level sequence's length
  SSSP = NaN(N,SSSPLength);    %Sorted Sequence's Stored Power ("pyramid")
                               %Can be used to visually represent tape
                               %stacks.
  
  headPos = ones(N,1);  %Set each tape's head to the start position 
  tapeMark = ones(N,1); %Guaranteed sorted order from beginning until tapemark
  i = 0;                %The head position on the input tape (V)
    
  Tapes = NaN(N, inputLength); %Simulated merger tapes. 
  MMT = 0;  %Main Merger Tape: where the next merging will be placed
  NTTW = 0; %Next Tape To Write:the next input read will be placed here 
  
  
  barchartnumber = 0; %For plotting only.
  
  %MAIN LOOP%
  while i < inputLength       
      SelectNextMainMergerTape_BeforePhase1; 
      phase1InternalSort;      
      phase2Merge;
      
      
      %for debug:
      %MYDEBUG = sum(~isnan(Tapes),2);
      %printCurrentStatus; %PLOTTING
         
      %If phase 3 merge(s) needed, calls them.
      numberP3 = GetRequiredPhase3Numer(i);      
      iter = 1;
      while (numberP3 >= iter)    
          
          if(iter == numberP3)
              [areEqualSequencesOnTop, extraP3Length] = CheckEqualSequencesOnTop;
              if(areEqualSequencesOnTop == false)
                  break;
              end;
          end
         
              SelectNextMainMergerTape_ForPhase3(iter + 1);
              phase3Merge(power(N-1,iter+1));

              %for debug:
              %MYDEBUG = sum(~isnan(Tapes),2);
              %printCurrentStatus; %PLOTTING
          
          iter = iter + 1;
      end %while      
      
      
      %Check if additional phase 3s become available
      [areEqualSequencesOnTop, extraP3Length] = CheckEqualSequencesOnTop;
      while (areEqualSequencesOnTop == true)
          SelectNextMainMergerTape_ForPhase3(extraP3Length +1);
          phase3Merge(power(N-1,extraP3Length + 1));
          
          %for debug:
          %MYDEBUG = sum(~isnan(Tapes),2);
          %printCurrentStatus; %PLOTTING
          
          [areEqualSequencesOnTop, extraP3Length] = CheckEqualSequencesOnTop;
      end %while
      
      
      if(numberP3>0)
          TryToDefragment;
          %for debug:
          %MYDEBUG = sum(~isnan(Tapes),2);
          %printCurrentStatus; %PLOTTING
      end;  
  end %while
  %END OF MAIN LOOP%
  
  

   %Phase 3 merge: merges "numItems" number of elements 
   %into descending or ascending order.
   function phase3Merge(numItems)
        
       counters(1:N) = (numItems/(N-1));       
       merges = 1;
       shouldTapeMarkAtEnd = false;
       %Taping at the end if MMT is empty
       if(headPos(MMT) == 1)
           shouldTapeMarkAtEnd = true;
       end %if
       
       %Check the current sorting order of a non MMT tape
       isInAscendingOrder = true;
       isOrderDetermined = false;
       aSample = 1;
       
       while(~isOrderDetermined && aSample <= N)
           if(aSample ~= MMT)
               numAccesses = numAccesses + 2;
               numComparisons = numComparisons + 1;
               if(Tapes(aSample, headPos(aSample) - 1) >  Tapes(aSample, headPos(aSample)))
                   isInAscendingOrder = false;
                   isOrderDetermined = true;
               else
                  %if the two consequent number were equal, compare with the beginning (spin the tape a lot)
                  numAccesses = numAccesses + 2;
                  numComparisons = numComparisons + 1;
                  if (Tapes(aSample, headPos(aSample) - 1) ==  Tapes(aSample, headPos(aSample)))
                       numAccesses = numAccesses + 2;
                       numComparisons = numComparisons + 1;
                       if (Tapes(aSample, headPos(aSample) - ((numItems/(N-1))-1) ) >  Tapes(aSample, headPos(aSample)))
                             isInAscendingOrder = false;   
                             isOrderDetermined = true;
                       else
                           numAccesses = numAccesses + 2;
                           numComparisons = numComparisons + 1;
                           if(Tapes(aSample, headPos(aSample) - ((numItems/(N-1))-1) ) ==  Tapes(aSample, headPos(aSample)))
                               isOrderDetermined = false; %continue looking.
                           else
                               isOrderDetermined = true;
                           end %if                           
                       end %if 
                  else
                      isOrderDetermined = true;
                  end %if          
               end %if
           end %if
           aSample = aSample + 1;
       end %while
       %End of checking the sort order.
       
       
       while (merges <= numItems)
       
           defaultMaxFound = false;
           m = 1;
           while (~defaultMaxFound)
               if((m ~= MMT) && (counters(m) ~= 0))
                   defaultMaxFound = true;
               else
                   m = m + 1;
               end %if               
           end %while
           
           numAccesses = numAccesses + 1;              
           minmax = Tapes(m, headPos(m)); %Becomes default min value
           minmaxTapeIndex = m; %Becomes default min index            
           m = m + 1; %skipping self-comparing
                        
           %Maximum selection from "top on the stack" numbers  
             while (m <= N)   
                 
               if(m ~= MMT)                         
                  if(counters(m) ~= 0)
                      
                     if(isInAscendingOrder == true)
                         numAccesses = numAccesses + 2;
                         numComparisons = numComparisons + 1;
                         if(Tapes(m, headPos(m)) > minmax)
                             numAccesses = numAccesses + 2;                  
                             minmax = Tapes(m, headPos(m));
                             minmaxTapeIndex = m;
                         end  %if 
                     else
                         numAccesses = numAccesses + 2;
                         numComparisons = numComparisons + 1;
                         if(Tapes(m, headPos(m)) < minmax)
                             numAccesses = numAccesses + 2;              
                             minmax = Tapes(m, headPos(m));
                             minmaxTapeIndex = m;
                         end  %if 
                     end
                  end %if
               end %if
               m = m + 1;
             end %while   
                   
           %Append the maximum into the main merger tape  
           numAccesses = numAccesses + 1;  
           if(~isnan(Tapes(MMT, headPos(MMT))))                               
                headPos(MMT) = headPos(MMT) + 1;
           end %end if
           numAccesses = numAccesses + 2;
           Tapes(MMT, headPos(MMT)) = minmax; 
           
           %Delete the selected number from the tape where it found
           numAccesses = numAccesses + 1;               
           Tapes(minmaxTapeIndex, headPos(minmaxTapeIndex)) = NaN;
           if(headPos(minmaxTapeIndex) ~= 1)
               headPos(minmaxTapeIndex) = headPos(minmaxTapeIndex) - 1;               
           end %if
           counters(minmaxTapeIndex) = counters(minmaxTapeIndex) - 1;
           
           %One more merged
           merges = merges + 1;
           
       end % while
       
       %Setting tapemark if needed
       if(shouldTapeMarkAtEnd == true)           
           tapeMark(MMT) = headPos(MMT);
       end %if
       ClearUpTapeMarks; %clears up tapemarks if needed
       
       %Updating Shortest Sorted Sequence Powers   
        myit = 1;
        while (myit<=SSSPLength && ~isnan(SSSP(MMT,myit)))
             myit = myit + 1; 
        end
        SSSP(MMT, myit) = floor(log(numItems)/log(N-1));
       
       
       
       myiter = 1;
       while myiter <= N
           if(myiter ~= MMT)
               if(headPos(myiter) == 1)
                   SSSP(myiter,1) = NaN;
                   SSSP(myiter,2:SSSPLength) = NaN;
               else
                   latestE = 1;
                   while(latestE <= SSSPLength && ~isnan(SSSP(myiter,latestE)))
                      latestE = latestE + 1; 
                   end
                   
                   if(latestE ~= 1)
                      latestE = latestE-1; 
                   end
                   
                   SSSP(myiter, latestE) = NaN;                   
                   
               end %if               
           end%if
           myiter = myiter + 1;
       end %while
       
   end %function phase3Merge
   

  %Phase 2 merge: merges the latest N-1 read values in ascending order.
  function phase2Merge
          
          merges = 1;
          while merges <= (N-1)


              %Select default min value (non-NaN)
              defaultMinFound = false;
              m = 1;
              while ~defaultMinFound
                  numAccesses = numAccesses + 1;                  
                  numComparisons = numComparisons + 1;
                  if((m ~= MMT) && ~isnan(Tapes(m, headPos(m))))
                      defaultMinFound = true;
                  else
                     m = m + 1; 
                  end%if
              end %while
              numAccesses = numAccesses + 1;
              min = Tapes(m, headPos(m)); %Becomes default min value
              minTapeIndex = m; %Becomes default min index            
              m = m + 1; %skipping self-comparing
              
              
              %Minimum selection from the latest reads     
                  while m <= N                  
                      if(m ~= MMT) 
                          numAccesses = numAccesses + 1;                          
                          numComparisons = numComparisons + 1;
                          if(~isnan(Tapes(m, headPos(m)))) 
                                  numAccesses = numAccesses + 2;
                                  numComparisons = numComparisons + 1;
                                  if(Tapes(m, headPos(m)) < min)
                                      numAccesses = numAccesses + 2;               
                                      min = Tapes(m, headPos(m));
                                      minTapeIndex = m;
                                  end  %if 
                          end %if
                      end %if
                      m = m + 1;
                  end %while   


              
              %Append the minimum into the main merger tape 
              numAccesses = numAccesses + 1;
              numComparisons = numComparisons + 1;
              if(~isnan(Tapes(MMT, headPos(MMT))))
                headPos(MMT) = headPos(MMT) + 1;
              end %end if
              numAccesses = numAccesses + 2;
              Tapes(MMT, headPos(MMT)) = min; 
              
                            
              %Delete the stored value from the tape where minimum found
              numAccesses = numAccesses + 1;
              Tapes(minTapeIndex, headPos(minTapeIndex)) = NaN;
              
              %One minimum found and merged.
              merges = merges + 1;            
            

          end %while
          
          myit = 1;
          while (myit<=SSSPLength && ~isnan(SSSP(MMT,myit)))
             myit = myit + 1; 
          end
          SSSP(MMT, myit) = 1;
          
          rewindNoneMainMergerWithOneStep;
   end %function

   %Multiples of pow(n-1,X) in "INPUTS" require X-1 "phase 3" merges 
   function numP3 = GetRequiredPhase3Numer(INPUTS)            
      isPh3Needed = (mod(INPUTS, power(N-1, 2)) == 0);
      
      if(isPh3Needed)          
        numP3 = 2;        
        pwrs = 2;
        while (power(N-1, pwrs) <= INPUTS)            
            fraction = mod(INPUTS / power(N-1, pwrs), 1);            
            if(fraction == 0)
                numP3 = pwrs;
            end%
            pwrs = pwrs + 1;
        end %while        
        numP3 = numP3 - 1;
        
      else
          numP3 = 0;
      end %if
   end %function
  
   %Moves back the non Main Merger tapes' head with one.
   function rewindNoneMainMergerWithOneStep
      tp = 1;
      while(tp <= N)
          if(tp ~= MMT && headPos(tp) ~= 1)              
              headPos(tp) = headPos(tp) - 1;
          end
          tp = tp + 1;
      end % while
   end %function 

   %Selects the next non main merger tape
    function FindNextTapeToWrite 
        NTTW = mod(NTTW, N) + 1;   
        if(NTTW == MMT)
            NTTW = mod(NTTW, N) + 1;   
        end %if   
    end %function FindNextTapeToWrite
   

    %Phase 1: Read in N-1 data from the input and writes to the tapes 
    function phase1InternalSort
        j = 1;
        while j <= (N-1)    
          i = i + 1; %Move input reader head 
          
          FindNextTapeToWrite;          
          
          %prevent overwriting if there is already a number at the head
          numAccesses = numAccesses + 1;           
          numComparisons = numComparisons + 1;               
          if(~isnan(Tapes(NTTW, headPos(NTTW))))
              headPos(NTTW) = headPos(NTTW) + 1;
          end %end if
          
          %Read from input, place to nextTapeToWrite
          numAccesses = numAccesses + 2;            
          Tapes(NTTW, headPos(NTTW)) = V(i);
                     

          j = j + 1;   
      end %while
    end % function phase1InternalSort


    %Selects a merger tape suitable for an (N-1)^X element merging
    function SelectNextMainMergerTape_ForPhase3 (SequenceSizePower)
        
       %Find a place where SSSP is SequenceSizePower + 1. 
       %If can't find, get one where <1
        isSuitableFound = false;
        secondaryOptionIndex = 0;
        tertiaryOptionIndex = 0;
        tertiaryOptionValue = NaN;
        iterator = 1;        
        while (~isSuitableFound && iterator <= N)
            
            %Find the top on the stack element
            Jiterator = 1;
            while(Jiterator<=SSSPLength && ~isnan(SSSP(iterator,Jiterator)))                 
                Jiterator = Jiterator + 1;
            end%while
            
            if(Jiterator == 1)
                secondaryOptionIndex = iterator;
                iterator = iterator + 1;
                continue;
            end;
            
            %Check if this element is suitable
            if(Jiterator<=SSSPLength)
                Jiterator = Jiterator - 1;
                
                if(isnan(tertiaryOptionValue))
                   tertiaryOptionValue =  SSSP(iterator,Jiterator);
                   tertiaryOptionIndex = iterator;
                end
                
                if(SSSP(iterator,Jiterator) == (SequenceSizePower + 1) && iterator <= N)
                    isSuitableFound = true;
                    MMT = iterator;
                    break;
                end %if 
                                
                
                if(SSSP(iterator,Jiterator) > tertiaryOptionValue)
                    tertiaryOptionIndex = iterator;
                end %if  
            end%if
            
            iterator = iterator + 1;
        end%while
        
        
        if(isSuitableFound == false)
            if(secondaryOptionIndex ~= 0)
                MMT = secondaryOptionIndex;
            else
                %No perfect matching space found.
                %Placing it on top of the longest sorted sequence (on top)
                MMT = tertiaryOptionIndex;                
            end%if
        end
        
        
        
    end %SelectNextMainMergerTape_ForPhase3
    

    %Selects the merger tape for the upcoming (n-1) number to be read.
    function SelectNextMainMergerTape_BeforePhase1
        
        %At the start, select the first tape as MMT
        if(i == 0)
            MMT = 1;
            return;
        end;
       
        %Find a place where SSSP is 2. If can't find, get one where <1
        isSuitableFound = false;
        secondaryOptionIndex = 0;
        tertiaryOptionIndex = 0;
        tertiaryOptionValue = NaN;
        iterator = 1;        
        while (~isSuitableFound && iterator <= N)
            
            %Find the top on the stack element
            Jiterator = 1;
            while(Jiterator<=SSSPLength && ~isnan(SSSP(iterator,Jiterator)))                 
                Jiterator = Jiterator + 1;
            end%while
            
            if(Jiterator == 1)
                secondaryOptionIndex = iterator;
                iterator = iterator + 1;
                continue;
            end;
            
            %Check if this element is suitable
            if(Jiterator<=SSSPLength)
                Jiterator = Jiterator - 1;
                
                if(isnan(tertiaryOptionValue))
                   tertiaryOptionValue =  SSSP(iterator,Jiterator);
                   tertiaryOptionIndex = iterator;
                end
                
                if(SSSP(iterator,Jiterator) == 2 && iterator <= N)
                    isSuitableFound = true;
                    MMT = iterator;
                    break;
                end %if  
                
                if(SSSP(iterator,Jiterator) > tertiaryOptionValue)
                    tertiaryOptionIndex = iterator;
                end %if  
            end%if
            
            iterator = iterator + 1;
        end%while
        
        
        if(isSuitableFound == false)
            if(secondaryOptionIndex ~= 0)
                MMT = secondaryOptionIndex;
            else
                %No perfect matching space found.
                %Placing it on top of the longest sorted sequence (on top)
                MMT = tertiaryOptionIndex;                
            end%if
        end
        
    end %function SelectNextMainMergerTape_BeforePhase1

    
    %Selects the first tape which has its head position at the tape mark
    %to be the MMT. Returns false if can't.
    function isMarkedTapeWithSpaceFound = SelectMarkedTapeWithSpace
        isMarkedTapeWithSpaceFound = false;
        
        iterator = 1;
        while ((iterator <= N) && (isMarkedTapeWithSpaceFound == false)) 
            if(headPos(iterator) == tapeMark(iterator))
                isMarkedTapeWithSpaceFound = true;
                MMT = iterator;
            end %if
            iterator = iterator + 1;
        end %while        
    end %function SelectEmptyTape

    
    %Selects the first empty tape to be the MMT. Returns false if can't.
    function isEmptyFound = SelectEmptyTape
        isEmptyFound = false;
        
        iterator = 1;
        while ((iterator <= N) && (isEmptyFound == false)) 
            if(headPos(iterator) == 1)
                isEmptyFound = true;
                MMT = iterator;
            end %if
            iterator = iterator + 1;
        end %while        
    end %function SelectEmptyTape

    %Reutrns true if all non MMT tapes head position are on the sem level
    function result = isAllNonMMTOnSameLevel
        result = true;    
        iterator = 1;
        Sample = 1;
        if(MMT == 1)
           Sample = 2; 
        end

        while (iterator <= N)
            if(iterator ~= MMT)
                result = (result && (headPos(t) == Sample));
            end;
            iterator = iterator + 1;
        end%while        
    end%

    %Selects the next tape in an oscillating manner (left to right)
    function SelectNextMainMergerTape_DefaultOscillating
        MMT = mod(MMT, N)+1;  
    end %function SelectNextMainMergerTape_DefaultOscillating

    %Sets the tapemark value to 1 if a Tape's head at 1 too.
    function ClearUpTapeMarks
        iterator = 1;
        while (iterator <= N)
            if(headPos(iterator) == 1)
                tapeMark(iterator) = 1;
            end;
            iterator = iterator + 1;
        end %while
    end %function


    %Ensures that a single vector returned as V output without magic numbers.
    function FinishingUp        
       
        hasDataCounter = 0;
        lastTapeWithData = 0;
        ab = 1;
        while(ab <= N)
            if(headPos(ab) ~= 1)
                hasDataCounter = hasDataCounter + 1;
                lastTapeWithData = ab;
            end
            ab = ab + 1;
        end%
        
        if(hasDataCounter == 1)
            if(hasMagicUsed == false)
                %Moving date from the tape to output
                numAccesses = numAccesses + (inputLength * 2);
                V = Tapes(lastTapeWithData,1:inputLength);                
                %Check if flipping is needed to have ascending order
                numAccesses = numAccesses + 1;
                numComparisons = numComparisons + 1;
                if(V(1) > V(inputLength))
                   numAccesses = numAccesses + (inputLength * 4); %inverting
                   V = fliplr(V); 
                end
            else
                numAccesses = numAccesses + (inputLength * 3);
                outputTape = Tapes(lastTapeWithData,1:inputLength);
                numComparisons = numComparisons + numel(outputTape);
                V = outputTape(outputTape~=MAGICNUMBER);
                numAccesses = numAccesses + numel(V);
                inputLength = numel(V);
                %Check if flipping is needed to have ascending order
                numComparisons = numComparisons + 1;
                if(V(1) > V(inputLength))                   
                   numAccesses = numAccesses + (inputLength * 4); %inverting
                   V = fliplr(V); 
                end
            end
        else
            %This should not happen (always has to end with 1 column)
            V = Tapes;
        end;        
    end %function



    %Checks if a tape starts with a sequence that has a length
    %one power shorter than a top sequence on an another tape.
    %If yes, calls the JoinTwoTapes function to merge them.
    %
    %NOTE on future improvements:
    %This could be be further improved to chech not only the beginning of
    %each tape, but looking at sub-sections of the tapes too. E.g.:
    %TAPE1: (N-1)^4; (N-1)^2; 
    %TAPE2: (N-1)^3;
    %TAPE3: (N-1)^1;
    %TAPE4: EMPTY
    %This would move ^1 to the top of ^2, but would miss the opportunity
    %to move ^2 to ^3, thus might resulting unsolvable fregmentation
    %down the road...
    function TryToDefragment
       
        iterator = 1;
        while(iterator <= N)
            %If SSPN is empty: skip
            if(isnan(SSSP(iterator,1)))
                iterator = iterator + 1;
                continue;
            end;
            
            %Get the size of the last ordered block
            Jiterator = 1;
            while(Jiterator<=SSSPLength && ~isnan(SSSP(iterator,Jiterator)))                 
                Jiterator = Jiterator + 1;
            end%while
            Jiterator = Jiterator - 1;
            
            %If it is the smallest possible block: skip
            if(SSSP(iterator,Jiterator) == 1)
              iterator = iterator + 1;
              continue;
            end;
                        
            %Find a tape that has a starting block 1 size bigger
            Miterator = 1;
            isTargetFound = false;
            while(Miterator <= N && ~isTargetFound)
                if(Miterator == iterator)
                   Miterator = Miterator + 1;
                   continue; 
                end%if
                
                if(~isnan(SSSP(Miterator,1)))                    
                    if(SSSP(Miterator,1) + 1 == SSSP(iterator,Jiterator))
                       isTargetFound = true;
                       break;
                    end  %if                   
                end %if
                Miterator = Miterator + 1;
            end %if
            
            %If suitable target found, then defragment
            if(isTargetFound == true)
                JoinTwoTapes(iterator, Miterator);
                continue;
            end            
           
            
            iterator = iterator + 1;
        end %while
    end


    %Joins two tapes by stacking one's content on top of the other.
    function JoinTwoTapes(staying, moving) 
          
        %Copy tape values
        copyIter = 1;
        while(copyIter <= headPos(moving))
            headPos(staying) = headPos(staying) + 1;
            numAccesses = numAccesses + 3;               
            Tapes(staying, headPos(staying)) = Tapes(moving, copyIter); 
            Tapes(moving, copyIter) = NaN;
            copyIter = copyIter + 1;
        end%while
        
        %Set heads and tapes
        headPos(moving) = 1;
        tapeMark(moving) = 1;
        
        %Join SSSP values
        ssspStayingIter = 1;        
        while(~isnan(SSSP(staying, ssspStayingIter)))
                          
           ssspStayingIter = ssspStayingIter + 1; 
        end
                
        ssspMovingIter = 1;
                      
        while(~isnan(SSSP(moving, ssspMovingIter)))                       
            SSSP(staying, ssspStayingIter) = SSSP(moving, ssspMovingIter);            
            SSSP(moving, ssspMovingIter) = NaN;
            ssspMovingIter = ssspMovingIter + 1;
            ssspStayingIter = ssspStayingIter + 1;            
        end%while       
    end%end function



    %Check if the (N-1) sequences on the top level have equal length.
    %If yes, returns the length of those sequences.
    function [hasEq, EqLength] = CheckEqualSequencesOnTop
        hasEq = false;
        EqLength = 0;
        
        %Get the length of the last sequence on each column
        lastSeqLengths = NaN(N,1);
        myi = 1;
        while(myi <= N )
            myx = 1;
            while(myx <= SSSPLength && ~isnan(SSSP(myi,myx)))
                lastSeqLengths(myi) = SSSP(myi,myx);
                myx = myx + 1;
            end                
            myi = myi + 1;
        end%while
        
        %Check if the top sequences on all columns have the same length 
        %with the exception of one column, If true, then merging is possible.
        nancounter = 0;        
        FL1counter = 1;
        foundLength2 = NaN;
        FL2counter = 0;
        foundLength1 = 0;
        myz = 1;
        
        if(~isnan(lastSeqLengths(1)))
            foundLength1 = lastSeqLengths(1);
            myz = 2;
        else
            nancounter = nancounter + 1;
            if(~isnan(lastSeqLengths(2)))
                foundLength1 = lastSeqLengths(2);
                myz = 3;
            else
                %There won't be an opportunity anyway now.
                nancounter = nancounter + 1;
            end
        end
        
        wasSearchSuccessfull = true;
        
        
        while(myz <= N && nancounter<2)
            if(nancounter == 2)
                %Two empty columns found. Cant have merging opportunity.
                wasSearchSuccessfull = false;
                break;
            end;
        
            if(isnan(lastSeqLengths(myz)))
               nancounter = nancounter + 1;
               myz = myz + 1;
               continue;
            end
            
            if(lastSeqLengths(myz) ~= foundLength1)
               if(isnan(foundLength2))
                  foundLength2 = lastSeqLengths(myz);
                  FL2counter = 1;
               else
                   if(lastSeqLengths(myz) ~= foundLength2)
                       %This is a third type of length. Cant have merging
                       %opportunity.
                       wasSearchSuccessfull = false;
                       break;
                   else
                      FL2counter = FL2counter + 1; 
                   end
               end
            else
                FL1counter = FL1counter + 1;
            end
            myz = myz + 1;
        end;%while
        
        if(nancounter == 1)
           if(~isnan(foundLength2))
               wasSearchSuccessfull = false;
           end            
        end
        
        if(FL1counter > 1 && FL2counter > 1)
            wasSearchSuccessfull = false;
        end
        
        
        %Check if opportunity found
        if((myz>=N) && (nancounter < 2) && wasSearchSuccessfull == true)
            hasEq = true;
            if(FL1counter > FL2counter)
                EqLength = foundLength1;
            else
                EqLength = foundLength2;
            end
        end
    end


    %Fills up the V to have (n-1)^X numbers
    function SetNumberOfTapesAndMagicNumbers
        N = 4;
        while (inputLength > power(N-1,SAFETOSTACK))
           N = N + 1; 
        end
        
        %If it is not exactly the same as the power number
        %then fill with magic numbers (which will be removed later)
        if(inputLength ~= power((N-1),SAFETOSTACK))   
            
            desiredLength = power((N-1),SAFETOSTACK); 
            differ = desiredLength - inputLength;
            magics(1:differ) = MAGICNUMBER;   
            numAccesses = numAccesses + differ;
            V = [V magics];
            hasMagicUsed = true;
            inputLength = desiredLength;
        end
    end

    %Prints out the current state of the pyramid to a file.
    %Can be used to create an animation by concatenating the images.
    function printCurrentStatus
%         barchartnumber = barchartnumber + 1;
%         filename = strcat(num2str(barchartnumber),'_oscil.jpg');  
%         fig = figure;        
%         set(fig, 'Visible', 'off');
%         elementscount = (N-1).^SSSP;
%         bar(elementscount, 'stacked'); 
%         title(strcat('Oscillating (merge) sort        (i = ', num2str(i), '; N = ', num2str(N),'; inputLength = ', num2str(inputLength), ';)'));
%         ylim([0 inputLength]);
%         xlabel('Merger tapes','FontSize', 12);
%         ylabel('Length of stacked sorted sequences','FontSize', 12);        
%         saveas(fig, filename, 'png');
    end
 
     FinishingUp;  
end % main function
