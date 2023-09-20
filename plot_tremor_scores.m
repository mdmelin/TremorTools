function [linear_fig, log_fig] = plot_tremor_scores(pre_scores, post_scores, title_string, ylabel_string)

onevec = ones(1,length(pre_scores));
twovec = onevec + 1;
linear_fig = figure;
labels = {'Pre-procedure','Post-procedure'};
boxplot([pre_scores;post_scores]',labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,pre_scores);
scatter(twovec,post_scores);
parallelcoords([pre_scores;post_scores]');
title(title_string);
ylabel(ylabel_string);
xL = xlim; yL = ylim;
text(0.9*xL(2),0.9*yL(2), ['N = ' num2str(length(pre_scores))], 'HorizontalAlignment','right','VerticalAlignment','top');

log_fig = figure;
logpre = log(pre_scores);
logpost = log(post_scores);
labels = {'Pre-procedure','Post-procedure'};
boxplot([logpre;logpost]',labels,'PlotStyle','traditional','OutlierSize',.0001);
hold on;
scatter(onevec,logpre);
scatter(twovec,logpost);
parallelcoords([logpre;logpost]');
title(title_string);
ylabel(['Log ' ylabel_string]);
xL = xlim; yL = ylim;
text(0.9*xL(2),0.9*yL(2), ['N = ' num2str(length(pre_scores))], 'HorizontalAlignment','right','VerticalAlignment','top');
end