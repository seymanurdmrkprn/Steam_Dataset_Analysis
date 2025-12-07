% Performance Panel 1: Game Characteristics Comparison
% Compares characteristics between top 100 and random 100 games

pkg load statistics;

% Read the characteristics data
data = csvread('../performance_panel1_characteristics.csv', 1, 1);  % Skip first column (Category names)

disp('Data loaded:');
disp(data);

% Extract data (Top 100=row1, Average 100=row2)
categories = {'Top 100', 'Average 100'};
avg_price = data(:, 1);      % Column 1: Avg_Price
avg_playtime = data(:, 2);   % Column 2: Avg_Playtime
avg_dlc = data(:, 3);        % Column 3: Avg_DLC_Count
avg_reviews = data(:, 4);    % Column 4: Avg_Reviews

% Create figure
fig = figure('Position', [100, 100, 1400, 900]);
set(fig, 'Color', [0.97, 0.97, 0.97]);

% Create 2x2 subplot layout
metrics = {'Avg Price ($)', 'Avg Playtime (hours)', 'Avg DLC Count', 'Avg Reviews'};
data_sets = {avg_price, avg_playtime, avg_dlc, avg_reviews};

% Color schemes for each metric (green for top, gray for random)
colors = {
    [0.2, 0.7, 0.3; 0.6, 0.6, 0.6],  % Green and Gray for Price
    [0.2, 0.7, 0.3; 0.6, 0.6, 0.6],  % Green and Gray for Playtime
    [0.2, 0.7, 0.3; 0.6, 0.6, 0.6],  % Green and Gray for DLC
    [0.2, 0.7, 0.3; 0.6, 0.6, 0.6]   % Green and Gray for Reviews
};

for i = 1:4
    subplot(2, 2, i);
    
    % Create bar chart
    vals = data_sets{i};
    
    % Draw bars using patch (manual rectangles)
    bar_width = 0.6;
    
    % First bar (Top 100) - Green
    x1 = [1-bar_width/2, 1+bar_width/2, 1+bar_width/2, 1-bar_width/2];
    y1 = [0, 0, vals(1), vals(1)];
    patch(x1, y1, colors{i}(1,:), 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    hold on;
    
    % Second bar (Random 100) - Gray
    x2 = [2-bar_width/2, 2+bar_width/2, 2+bar_width/2, 2-bar_width/2];
    y2 = [0, 0, vals(2), vals(2)];
    patch(x2, y2, colors{i}(2,:), 'EdgeColor', [0.3, 0.3, 0.3], 'LineWidth', 1.5);
    
    hold off;
    
    % Add value labels
    for j = 1:2
        val = vals(j);
        if val >= 1000000
            label = sprintf('%.1fM', val/1000000);
        elseif val >= 100000
            label = sprintf('%.0fK', val/1000);
        elseif val >= 1000
            label = sprintf('%.1fK', val/1000);
        elseif val >= 100
            label = sprintf('%.0f', val);
        elseif val >= 10
            label = sprintf('%.1f', val);
        else
            label = sprintf('%.2f', val);
        end
        text(j, val + max(vals)*0.08, label, ...
             'HorizontalAlignment', 'center', 'FontSize', 13, 'FontWeight', 'bold');
    end
    
    % Styling
    set(gca, 'XTick', [1, 2]);
    set(gca, 'XTickLabel', categories);
    set(gca, 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'Color', [1, 1, 1]);
    
    % Y axis formatting - prevent scientific notation
    if i == 4  % Reviews panel
        set(gca, 'YTickLabelMode', 'manual');
        yticks_vals = get(gca, 'YTick');
        ytick_labels = {};
        for k = 1:length(yticks_vals)
            if yticks_vals(k) >= 1000000
                ytick_labels{k} = sprintf('%.0fM', yticks_vals(k)/1000000);
            elseif yticks_vals(k) >= 1000
                ytick_labels{k} = sprintf('%.0fK', yticks_vals(k)/1000);
            else
                ytick_labels{k} = sprintf('%.0f', yticks_vals(k));
            end
        end
        set(gca, 'YTickLabel', ytick_labels);
    end
    
    ylabel(metrics{i}, 'FontSize', 17, 'FontWeight', 'bold');
    grid on;
    set(gca, 'GridAlpha', 0.15);
    set(gca, 'Layer', 'top');
    xlim([0.5, 2.5]);
    ylim([0, max(vals)*1.2]);
    
    % Individual title for each subplot
    title(metrics{i}, 'FontSize', 17, 'FontWeight', 'bold');
end

% Add main title using text annotation
annotation('textbox', [0.25, 0.94, 0.5, 0.05], ...
    'String', 'Game Characteristics: Top 100 vs Average 100 Games', ...
    'FontSize', 20, 'FontWeight', 'bold', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'BackgroundColor', [0.97, 0.97, 0.97]);

% Save the figure
print('-dpng', '-r300', 'performance_panel1_characteristics.png');

disp('Performance Panel 1: Game characteristics comparison saved!');
