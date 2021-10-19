%
% Total cases and total deaths in revacinating vs. testing efficacy 
% Loads and plots the final numbers vs. testing efficacy 
%

clear; close all

% Input
% Town population
n_pop = 79205;
% Number of independent simulations in each set
num_sim = 100;
% Common file name
mname = 'dir';

% Files to consider
dir_names = dir([mname, '_*']);
dir_names = {dir_names.name};
ndirs = length(dir_names);
% Extract the numbers in file endings 
str=sprintf('%s#%s#', dir_names{:});
num = sscanf(str, [mname,'_%f_%d#']);
% Numbers to consider
vac_num = sort(unique(num(2:2:end)));
tst_num = sort(unique(num(1:2:end)));
% For array sizes
n_vac = length(vac_num);
n_tst = length(tst_num);

% These will be average values over all realizations
total_cases = zeros(n_vac, n_tst);
total_deaths = zeros(n_vac, n_tst);

% x (%Sy tested) and y (vaccination) axes
testing_Sy = tst_num;
vac_rates = vac_num;

for ii = 1:n_vac
    for jj = 1:n_tst
        % Name of the directory, this may crash if the numbers are not in
        % the same format as the ones in the directory name
        str = sprintf('%.1f',tst_num(jj));
        str = regexprep(str,'([1-9])[0]+','$1');
        dname = sprintf([mname,'_%s_%d'], str, vac_num(ii));
        fprintf('Processing: %s\n', dname)
        temp = load([dname,'/sim_results.mat']);
        % Averages over all realizations
        total_deaths(ii,jj) = mean(temp.tot_deaths(:,end));
        total_cases(ii,jj) = mean(temp.tot_infected(:,end));
    end
end

%
% Plot results from all simulations
%

% Plot settings


% Color for the largest value in the heatmap
max_clr = [12, 5, 125]/255;
% Number of colors to use (lowest is white)
clr_points = 20;

plot_title = 'Total deaths';
ylimits = [0,2.5e3];
clevels = [10, 20, 100, 300, 600, 1000, 1500];
cb_ticks = [0, 500, 1000, 1500, 2000, 2.5e3];
cb_tick_labels = {'0', '0.5', '1', '1.5', '2', '2.5'};
plot_heatmap(testing_Sy, vac_rates, total_deaths, 1, plot_title, max_clr, clr_points, ylimits(2), 1, n_pop, cb_ticks, cb_tick_labels, clevels)

plot_title = 'Total infected';
ylimits = [0,4e5];
clevels = [2e4, 3e4, 5e4, 1e5, 2e5, 3e5];
cb_ticks = [0, 1e5, 2e5, 3e5, 4e5];
cb_tick_labels = {'0', '1', '2', '3', '4'};

plot_heatmap(testing_Sy, vac_rates, total_cases, 2, plot_title, max_clr, clr_points, ylimits(2), 1, n_pop, cb_ticks, cb_tick_labels, clevels)

function plot_heatmap(x, y, values, i, ylab, max_clr, clr_points, clim, use_percent, n_pop, cb_ticks, cb_tick_labels, clevels)

    % Create figure
    figure1 = figure(i);
   
    % Convert to %
    x = x'*100;
    
    % Convert number of residents to percent population
    if use_percent
        y = y/n_pop*100;
    end
    
    % First check the acutal limits, then restrict ColorLimits - otherwise
    % biased
%     h = heatmap(x,y,values,'Title', ylab, 'CellLabelColor','none');
    h = heatmap(x,y,values,'Title', ylab, 'CellLabelColor','none', 'ColorLimits', [0,clim], ...
        'InnerPosition',[0.177438591597373 0.191765170084011 0.6530877241921 0.708234829915988]);
  
    % Create custom colormap
    colorMap = [linspace(1,max_clr(1),clr_points)', ...
                linspace(1,max_clr(2),clr_points)',...
                linspace(1,max_clr(3),clr_points)'];
    colorMap = colorMap(2:end,:);
    colormap(h, colorMap)
    h.GridVisible = 'off';
    
%     % Labels
%     h.XLabel = 'Reopening rate, %/day';
%     if use_percent
%         h.YLabel = ['Vaccination rate,', newline, '%(population)/day'];
%     else
%         h.YLabel = 'Vaccination rate, people/day';
%     end
  
    % This should be preceeded by examining the range
    % Customize y ticks if using percents
    if use_percent
        % First check
        CustomYLabels = {'0.01', '0.02', '0.05', '0.1', '0.2', '0.5', '1', '2', '5'};
        h.YDisplayLabels = CustomYLabels;
    else
        h.YDisplayLabels = {'5', '50', '100', '250', '500', '750', '1,000', ...
                           '2,500', '5,000', '8,000'};
    end
    h.YDisplayData = flipud(h.YDisplayData); 
                    
    % Adjust colobar 
    hCB=h.NodeChildren(2);         
    hCB.Ticks = cb_ticks;
    hCB.TickLabels = cb_tick_labels;
      
    % Fonts
    h.FontName = 'Arial';
    h.FontSize = 28;
   
    % Size
    set(gcf,'Position',[200 500 950 750])
    
        
  
    % Contours
    hAx = axes('Position',h.Position,'Color','none'); 
    hold on
    [M,c] = contour(hAx,round(values),clevels, 'ShowText','on','LevelList',clevels);
    clabel(M,c,'FontSize',22,'Color','k', 'FontName', 'Arial');
%     
%     for itn = 1:length(texth)
%         textstr=get(texth(itn),'String');
%         textnum=str2num(textstr);
%         textstrnew=num2str(textnum,'%,.0f');
%         set(texth(n),'String',teststrnew);
%     end
%     c.YAxis.TickLabelFormat = '%,.0f';
    % To see what is available
%      [M,c] = contour(hAx,round(values),5, 'ShowText','on')
    c.LineWidth = 2.5;
    c.LineColor = 'k';
    axis(hAx,'tight');
    hold(hAx,'off');
    % Set the remaining axes properties
    set(hAx,'Color','none','XTick',zeros(1,0),'YTick',zeros(1,0));

    
 
end