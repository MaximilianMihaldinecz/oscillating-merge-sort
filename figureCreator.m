%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title:            Figure creator for sorting test harnesses
% Author:           SID: 1402184
% Original author:  Ian van der Linde
% Rev. Date:        03 May 2016
%
% Load in the saved sorting test result workspaces to generate the plots.
% If printing needed, uncomment the last line and set the file name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


presortedFig = figure;
presortedFig.PaperType = 'a4';
presortedFig.PaperOrientation = 'portrait';
errorbarGapSize = 200;

%%Comparisons
%%
subplot(3,1,1);
%Bubble
p1 = plot(1:maxArrayLength, bubbleSort_comparisons_mean,'LineWidth', 3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, bubbleSort_comparisons_mean(1:errorbarGapSize:end), bubbleSort_comparisons_SD(1:errorbarGapSize:end), 'ko');hold on;
%Pancake
p2 = plot(1:maxArrayLength, pancakeSort_comparisons_mean,'LineWidth', 3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, pancakeSort_comparisons_mean(1:errorbarGapSize:end), pancakeSort_comparisons_SD(1:errorbarGapSize:end), 'ko');
%Oscillation
p3 = plot(1:maxArrayLength, oscillationSort_comparisons_mean,'LineWidth', 3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, oscillationSort_comparisons_mean(1:errorbarGapSize:end), oscillationSort_comparisons_SD(1:errorbarGapSize:end), 'ko');
legend([p1,p2,p3],'Bubble','Pancake','Oscillating','Location','northwest');

xlabel('Array Length','FontSize', 10);
ylabel('Comparisons','FontSize', 11);
xlim([0 maxArrayLength]);

%ylim
bestForCompareYLim = (1:3);
bestForCompareYLim(1) = max(bubbleSort_comparisons_mean);
bestForCompareYLim(2) = max(pancakeSort_comparisons_mean);
bestForCompareYLim(3) = max(oscillationSort_comparisons_mean);
ylim([0 max(bestForCompareYLim)]);


%%Memory accesses
%%
subplot(3,1,2);
%Bubble
p4 = plot(1:maxArrayLength, bubbleSort_memAccess_mean,'LineWidth',3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, bubbleSort_memAccess_mean(1:errorbarGapSize:end), bubbleSort_memAccess_SD(1:errorbarGapSize:end), 'ko');
%Pancake
p5 = plot(1:maxArrayLength, pancakeSort_memAccess_mean,'LineWidth',3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, pancakeSort_memAccess_mean(1:errorbarGapSize:end), pancakeSort_memAccess_SD(1:errorbarGapSize:end), 'ko');
%Oscillation
p6 = plot(1:maxArrayLength, oscillationSort_memAccess_mean,'LineWidth',3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, oscillationSort_memAccess_mean(1:errorbarGapSize:end), oscillationSort_memAccess_SD(1:errorbarGapSize:end), 'ko');
legend([p4,p5,p6],'Bubble','Pancake','Oscillating','Location','northwest');

xlabel('Array Length','FontSize', 10);
ylabel('Memory Accesses','FontSize', 11);
xlim([0 maxArrayLength]);

%ylim
bestForAccessYLim = (1:3);
bestForAccessYLim(1) = max(bubbleSort_memAccess_mean);
bestForAccessYLim(2) = max(pancakeSort_memAccess_mean);
bestForAccessYLim(3) = max(oscillationSort_memAccess_mean);
ylim([0 max(bestForAccessYLim)]);


%%Time elapsed
%%
subplot(3,1,3);
%Bubble
p7 = plot(1:maxArrayLength, bubbleSort_elapsedTime_mean, 'LineWidth',3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, bubbleSort_elapsedTime_mean(1:errorbarGapSize:end), bubbleSort_elapsedTime_SD(1:errorbarGapSize:end), 'ko');
%Pancake
p8 = plot(1:maxArrayLength, pancakeSort_elapsedTime_mean, 'LineWidth',3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, pancakeSort_elapsedTime_mean(1:errorbarGapSize:end), pancakeSort_elapsedTime_SD(1:errorbarGapSize:end), 'ko');
%Oscillation
p9 = plot(1:maxArrayLength, oscillationSort_elapsedTime_mean, 'LineWidth',3);hold on;
errorbar(1:errorbarGapSize:maxArrayLength, oscillationSort_elapsedTime_mean(1:errorbarGapSize:end), oscillationSort_elapsedTime_SD(1:errorbarGapSize:end), 'ko');
legend([p7,p8,p9],'Bubble','Pancake','Oscillating','Location','northwest');

xlabel('Array Length','FontSize', 10);
ylabel('Elapsed Time (s)','FontSize', 11);
xlim([0 maxArrayLength]);
ylim([0 max(pancakeSort_elapsedTime_mean)]);

%ylim
bestForTimeYLim = (1:3);
bestForTimeYLim(1) = max(bubbleSort_elapsedTime_mean);
bestForTimeYLim(2) = max(pancakeSort_elapsedTime_mean);
bestForTimeYLim(3) = max(oscillationSort_elapsedTime_mean);
ylim([0 max(bestForTimeYLim)]);

%%
%print -f1 -dpng -r1200 sortResults.png
