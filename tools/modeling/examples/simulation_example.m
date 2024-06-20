rng(0);
clear
clc
close all

% sigma_list = [0 1  3  5 10 20];
 sigma_list = [5 10  15  20 30 35];
% sigma_list = 5;

for c1 = 1:size(sigma_list,2)
    
    % Specify model and input space
    input_space_1             = (0:.005:1)';
%   input_space_2             = (0:.05:1);


    objective_model                 = forrester_model;
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
    y_noise                 = std(y_data);

     CNR(c1)                 = y_contrast / y_noise; 
    %CNR originally a 1x6 
%     CNR                     = [2.5 2.5 2.5 2.5 2.5 2.5];
 
  
    

%     for c3 = 1:100
%         for c2 = 1:50
%             n_samples               = c2;
%             x_inputs                = linspace(0,1, 5);
%             x_anova                 = repmat(x_inputs,n_samples,1);
%             x_anova_list            = reshape(x_anova, [], 1);
% 
%             y_anova_list            = objective_model.sample(x_anova_list);
% 
%             group_mean              = mean(y_anova_list);
%             y_anova                 = reshape(y_anova_list, [], 5);
% 
%             y_mean                  = mean(y_anova);
%             [~, max_idx]            = max(y_mean);
% 
%             X_opt_est(c3,c2)        = x_inputs(max_idx);
%             Y_opt_est(c3,c2)        = objective_model.predict(X_opt_est(c3,c2));
%         end
%     end
    %%
    % Run simulation

    n_trials    = 20;
    n_samples   = 100;
    n_burn_in   = 10;
    params      = [3 1];
    setpoint    = [];
    
    [X_samples, Y_samples, X_optimal_est, y_optimal_est] = bayes_opt_loop(objective_model, n_trials, n_samples, n_burn_in, params, setpoint);
    
    % Calculate Y error

    y_error(:,c1) = abs(y_optimal_est(end,:) - max(y_est));
    
% %      y_error(:,c1) = y_error(:,c1)./ (max(y_optimal_est(:,c1)) - min(y_optimal_est(:,c1)));
%      y_error(:,c1) = y_error(:,c1)./ y_contrast;

% x_error(:, c1) = 
    
    % Calculate Y convergence rate

    sample_numbers  = (1:n_samples)';


    Y_rate(:,c1)          = error_convergence_rate(sample_numbers, y_optimal_est, max(y_est));


end
%%

% 
% for c1 = 1:size(sigma_list,2)
%     plot(length_scale(c1)
% 
% make lengthscales (iterative)
% 

subplot(2,1,1)


% hold on
% for c1 = 1:size(sigma_list,2)
%     plot(CNR(c1), y_error(:,c1), 'x', 'color', .5*ones(1,3))
% end
% errorbar(CNR, mean(y_error), std(y_error)/sqrt(20), 'color', 'k', 'linewidth', 2);

y_25                    = prctile(y_error, 25);
y_50                    = prctile(y_error, 50);
y_75                    = prctile(y_error, 75);
y_100                   = prctile(y_error, 100);
y_0                     = prctile(y_error, 0);

y_25_75                 = [y_25  flip(y_75)]';

CNR_y_error             = [CNR; y_error]; %21x6 where the first row is the CNR values

t                       = CNR; 

tt                      = [t flip(t)]';

patch(tt, y_25_75,'red', 'facealpha', 0.5)
hold on 
plot(t, y_50)
plot(t, y_100, 'b--o')
plot(t, y_0, 'b--o')



%gotta do the same thing with the X_error and convergence rate for the plot
%figures 

ylabel('Final Y-error')
set(gca, 'FontSize', 16)

subplot(2,1,2)

hold on
for c1 = 1:size(sigma_list,2)
    plot(CNR(c1), Y_rate(:,c1), 'x', 'color', .5*ones(1,3))
end
errorbar(CNR, mean(Y_rate), std(Y_rate), 'color', 'k', 'linewidth', 2);

xlabel('Contrast-to-Noise Ratio');
ylabel('Convergence Rate')
set(gca, 'FontSize', 16)
