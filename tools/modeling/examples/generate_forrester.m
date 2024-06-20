rng(0);
clear
clc
close all

%  sigma_list = [0 1  3  5 10 20];
  sigma_list = [5 10  15  20 30 35];
%  sigma_list = 6;

for c1 = 1:size(sigma_list,2)
    
    % Specify model and input space
    input_space_1             = (0:.005:1)';
%   input_space_2             = (0:.05:1);


    objective_model                 = goldstein_price_model;
    objective_model.noise_sigma     = sigma_list(c1);

%   input_space             = combvec(input_space_1, input_space_2)';
    input_space             = input_space_1;

    y_data                  = objective_model.sample(input_space);

    % Calculate length scale
%     objective_model         = gp_object;
%     objective_model.initialize_data(input_space, y_data);
%     objective_model.minimize(10);

%     length_scale = objective_model.hyperparameters.cov;
    
    y_est                   = objective_model.predict(input_space);
    y_contrast              = max(y_est) - min(y_est);
%normalize contrast for CNR calculation    
    test                    = 100.*randn(1,10);
    min_val                 = min(test);
    max_val                 = max(test);
    y_contrast_norm         = (test - min_val) / ( max_val - min_val);
    y_noise                 = std(y_data);
%difference of the mean for the CNR calculation
    y_contrast_mean
     CNR(c1)                 = y_contrast / y_noise; 

end 