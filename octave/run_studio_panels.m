% Run all Studio Comparison panels
% Generates 4 visualization panels comparing Indie vs Mid-tier vs AAA studios

clear all; close all; clc;

fprintf('========================================\n');
fprintf('STUDIO COMPARISON PANELS\n');
fprintf('========================================\n\n');

% Change to panels directory
cd('panels');

% Panel 1: Pricing Strategy
fprintf('Panel 1: Pricing Strategy...\n');
run('studio_panel1_pricing.m');
close all;
fprintf('Done!\n\n');

% Panel 2: Quality Metrics
fprintf('Panel 2: Quality & Engagement...\n');
run('studio_panel2_quality.m');
close all;
fprintf('Done!\n\n');

% Panel 3: Playtime & Content
fprintf('Panel 3: Playtime & Content...\n');
run('studio_panel3_content.m');
close all;
fprintf('Done!\n\n');

% Panel 4: Platform Support
fprintf('Panel 4: Platform Support...\n');
run('studio_panel4_platforms.m');
close all;
fprintf('Done!\n\n');

fprintf('========================================\n');
fprintf('ALL STUDIO PANELS COMPLETE!\n');
fprintf('Check outputs/images/ for:\n');
fprintf('  - studio_panel1_pricing.png\n');
fprintf('  - studio_panel2_quality.png\n');
fprintf('  - studio_panel3_content.png\n');
fprintf('  - studio_panel4_platforms.png\n');
fprintf('========================================\n');
