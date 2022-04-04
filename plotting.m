close all;
figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([pre,post],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,pre);
scatter(twovec,post);
parallelcoords([pre,post]);
title('APDM Sensors - Wing-Beating Tremor');
ylabel('Tremor Index (AU)');

%%
figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([logpre,logpost],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,logpre);
scatter(twovec,logpost);
parallelcoords([logpre,logpost]);
title('APDM Sensors - Wing-Beating Tremor');
ylabel('Log Tremor Index (AU)');
%%

figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([pre2,post2],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onev,pre2);
scatter(twov,post2);
parallelcoords([pre2,post2]);
title('Wacom Tablet - Small and Large Spirals');
ylabel('Tremor Index (AU)');

%%

figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([logpre2,logpost2],labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onev,logpre2);
scatter(twov,logpost2);
parallelcoords([logpre2,logpost2]);
title('Wacom Tablet - Small and Large Spirals');
ylabel('Log Tremor Index (AU)');

