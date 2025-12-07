% MASTER SCRIPT: Create All Advanced Panels (21-24)
% Run all advanced panel creation scripts sequentially

fprintf('===========================================================\n');
fprintf('CREATING ALL ADVANCED PANELS (21-24)\n');
fprintf('Using full dataset: steam_games.csv (83,560 games)\n');
fprintf('===========================================================\n\n');

tic;  % Start timer

% Panel 21: Scatter Plot - Price vs Rating
fprintf('>>> Creating Panel 21: Scatter Plot Analysis...\n');
try
    create_panel21_scatter;
    fprintf('    SUCCESS: Panel 21 created\n\n');
catch err
    fprintf('    ERROR: %s\n\n', err.message);
end

% Panel 22: Box Plot - Review Distribution
fprintf('>>> Creating Panel 22: Box Plot Analysis...\n');
try
    create_panel22_boxplot;
    fprintf('    SUCCESS: Panel 22 created\n\n');
catch err
    fprintf('    ERROR: %s\n\n', err.message);
end

% Panel 23: Line Chart - Yearly Trends
fprintf('>>> Creating Panel 23: Line Chart Analysis...\n');
try
    create_panel23_linechart;
    fprintf('    SUCCESS: Panel 23 created\n\n');
catch err
    fprintf('    ERROR: %s\n\n', err.message);
end

% Panel 24: Stacked Bar - Platform Analysis
fprintf('>>> Creating Panel 24: Stacked Bar Analysis...\n');
try
    create_panel24_stackedbar;
    fprintf('    SUCCESS: Panel 24 created\n\n');
catch err
    fprintf('    ERROR: %s\n\n', err.message);
end

elapsed = toc;  % Get elapsed time

fprintf('===========================================================\n');
fprintf('ALL ADVANCED PANELS CREATION COMPLETE!\n');
fprintf('===========================================================\n\n');
fprintf('Total time: %.1f seconds\n', elapsed);
fprintf('Created panels:\n');
fprintf('  21. advanced_panel21_scatter_price_rating.png\n');
fprintf('  22. advanced_panel22_boxplot_reviews.png\n');
fprintf('  23. advanced_panel23_linechart_trends.png\n');
fprintf('  24. advanced_panel24_stackedbar_platform.png\n\n');
fprintf('Total panel count in workspace: 24 panels\n');
fprintf('  - Original panels: 1-20\n');
fprintf('  - Advanced panels: 21-24 (NEW)\n\n');
