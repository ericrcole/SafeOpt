function [X_opt, Y_opt, X_sample, Y_sample, Y_safety] = safe_opt_on_model_ND(objective_model, safety_model,...
    threshold, beta, eta, alpha, PLOT, input_space, y_bounds, safe_seed, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT)

n_safe          = size(safe_seed,1);
X_sample        = safe_seed;
% Y_sample        = min(y_bounds(2,1), objective_model.sample(safe_seed));
% Y_safety        = max(y_bounds(1,2), safety_model.sample(safe_seed));
Y_sample        = objective_model.sample(safe_seed);
Y_safety        = safety_model.sample(safe_seed);

if all(Y_sample == 1)
   Y_sample(2) = 0.99;
end
safe_set        = zeros(size(input_space,1),1);
%safe_set(input_space > max(safe_seed)) = 0;
safe_set(all(input_space<1,2)) = 1;

for c1 = n_safe+1:n_samples
        

    [x_sample, x_opt, y_opt, safe_set] = safe_opt_update_ND(X_sample, Y_sample, beta, eta, alpha, ...
            safe_set, threshold, input_space, USE_HYPERPRIOR, USE_SAFE_OPT, PLOT);
        
    y_sample                = objective_model.sample(x_sample);  
%     y_sample                = max(y_sample, y_bounds(1,1));
%     y_sample                = min(y_sample, y_bounds(2,1));
%     y_sample                = max(y_sample, y_bounds(1,1));
%     y_sample                = min(y_sample, y_bounds(2,1));


    y_safety                = safety_model.sample(x_sample);  
%     y_safety                = max(y_safety, y_bounds(1,2));
%     y_safety                = min(y_safety, y_bounds(2,2));
%     y_safety                = max(y_safety, y_bounds(1,2));
%     y_safety                = min(y_safety, y_bounds(2,2));
%     y_safety                = round(y_safety);
    
    X_sample(c1,:)          = x_sample;
    Y_sample(c1,1)          = y_sample;
    Y_safety(c1,1)          = y_safety;
    
    X_opt(c1,:)             = x_opt;
    Y_opt(c1,:)             = y_opt;
    
    if 0
        
        subplot(2,3,3); hold off
        plot(1:c1, X_sample(:,1), '--')
        hold on
        plot(1:c1, X_opt(:,1), '-', 'LineWidth', 2)
        xlim([1 n_samples])
        
        subplot(2,3,6); hold off
        plot(1:c1, X_sample(:,2), '--')
        hold on
        plot(1:c1, X_opt(:,2), '-', 'LineWidth', 2)
        xlim([1 n_samples])

        drawnow            
    end
end
end