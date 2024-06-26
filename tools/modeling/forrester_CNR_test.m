rng(0);
clear
clc
close all

sigma_1 = [40 30 20 13];
sigma_2 = [13 10 7 5.5];
sigma_3 = [5.5 3 1.5 0.1];
sigma_all = [sigma_1 
    sigma_2 
    sigma_3]';


for a1 = 1:size(sigma_all,1)
    
    sigma_list = sigma_all(:,a1);

for c1 = 1:size(sigma_list,2)
    
    
    % Specify model and input space
    
    %1 Dimensional Model initialization
    input_space_1             = (0:0.005:1)';
    strap                      = zeros(size(input_space_1,1),1);
    strap(:,1)                 = input_space_1;
%     strap(:,2)                 = input_space_1;
%     strap(:,3)                 = input_space_1;
    input_space_1D            = strap;
    
    
    objective_model_1                 = forrester_model;
    
    
    objective_model_1.noise_sigma     = sigma_list(c1);
    
    
    input_space_1             = input_space_1D;
    
    
    
    y_data_1                  = objective_model_1.sample(input_space_1);
    
    
    y_est_1                   = objective_model_1.predict(input_space_1);
    
    
    
    y_contrast_1              = max(y_est_1) - min(y_est_1);
    
    %normalize contrast for CNR calculation
    test                    = 100.*randn(1,10);
    min_val                 = min(test);
    max_val                 = max(test);
    y_contrast_norm         = (test - min_val) / ( max_val - min_val);
    
    
    y_noise_1                 = std(y_data_1);
    
    
    CNR_1(c1)                 = y_contrast_1 / y_noise_1;
    
    
end

y_plot(:, a1)          = y_est_1;

end 



% y_1 = y_plot(:,1);
% y_2 = y_plot(:,2);
% y_3 = y_plot(:,3);
% 
% plot(input_space_1D,y_1)
% hold on
% plot(input_space_1D, y_2)
% plot(input_space_1D, y_3)








