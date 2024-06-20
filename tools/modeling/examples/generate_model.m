
rng(0);
clear
clc
close all

%  sigma_list = [0 1  3  5 10 20];
   sigma_list = [13 10 7 5.5];
%     sigma_list = [40 30 20 13];


%noise for each model is the same for each run

for c1 = 1:size(sigma_list,2)
    
    
    % Specify model and input space
    
    %1 Dimensional Model initialization
    input_space_1             = (0:0.005:1)';
    strap                      = zeros(size(input_space_1,1),1);
    strap(:,1)                 = input_space_1;
%     strap(:,2)                 = input_space_1;
%     strap(:,3)                 = input_space_1;
    input_space_1D            = strap;
    
    
    
%     % %2 Dimensional Model initialization
%     input_space_2             = (0:.005:1)';
%     munny                     = zeros(size(input_space_2,1), 2);
%     munny(:,1)                = input_space_2;
%     munny(:,2)                = input_space_2;
%     input_space_2D            = munny;
%     
%     
%     %3 Dimensional Model initialization
%     input_space_3             = (0:0.005:1)';
%     gang                      = zeros(size(input_space_3,1),3);
%     gang(:,1)                 = input_space_3;
%     gang(:,2)                 = input_space_3;
%     gang(:,3)                 = input_space_3;
%     input_space_3D            = gang;
%     
    
    
    
%     objective_model_3                 = hartmann_model;
%     objective_model_2                 = goldstein_price_model;
    objective_model_1                 = forrester_model;
    
%     objective_model_3.noise_sigma     = sigma_list(c1);
%     objective_model_2.noise_sigma     = sigma_list(c1);
    objective_model_1.noise_sigma     = sigma_list(c1);
    
    
    %   input_space             = combvec(input_space_1, input_space_2)';
    %   adjust input space to reflect model dimensions
    
%     input_space_3             = input_space_3D;
%     input_space_2             = input_space_2D;
    input_space_1             = input_space_1D;
    
    
%     y_data_3                  = objective_model_3.sample(input_space_3);
%     y_data_2                  = objective_model_2.sample(input_space_2);
    y_data_1                  = objective_model_1.sample(input_space_1);
    
    % Calculate length scale
    %     objective_model         = gp_object;
    %     objective_model.initialize_data(input_space, y_data);
    %     objective_model.minimize(10);
    
    %     length_scale = objective_model.hyperparameters.cov;
    
%     y_est_3                   = objective_model_3.predict(input_space_3);
%     y_est_2                   = objective_model_2.predict(input_space_2);
    y_est_1                   = objective_model_1.predict(input_space_1);
    
    
%     y_contrast_3              = max(y_est_3) - min(y_est_3);
%     y_contrast_2              = max(y_est_2) - min(y_est_2);
    y_contrast_1              = max(y_est_1) - min(y_est_1);
    
    %normalize contrast for CNR calculation
    test                    = 100.*randn(1,10);
    min_val                 = min(test);
    max_val                 = max(test);
    y_contrast_norm         = (test - min_val) / ( max_val - min_val);
    
%     y_noise_3                 = std(y_data_3);
%     y_noise_2                 = std(y_data_2);
    y_noise_1                 = std(y_data_1);
    %difference of the mean for the CNR calcul_ation
    %     y_contrast_mean
%     CNR_3(c1)                 = y_contrast_3 / y_noise_3;
%     CNR_2(c1)                 = y_contrast_2 / y_noise_2;
    CNR_1(c1)                 = y_contrast_1 / y_noise_1;
    
end
