function [cost, E_MSE] = cross_validate_gp(X, Y, cv_size)

if nargin < 3
    cv_size     = 5;
end

indices     = crossvalind('Kfold', size(X,1), cv_size);

for c1 = 1:cv_size
        
    fprintf('\tFold: %d\n',c1);

    train       = indices ~= c1;
    test        = indices == c1;
    
    X_train     = X(train, :);
    X_test      = X(test, :);
    Y_train     = Y(train, :);
    Y_test      = Y(test, :);
    
    lower_bound = min(X_train);
    upper_bound = max(X_train);
    
    gp_model = gp_object();
    gp_model.initialize_data(X_train, Y_train, lower_bound, upper_bound)
    gp_model.minimize(10);
    
    try
        [Y_est, Y_std]  = gp_model.predict(X_test);  
        E_MSE(c1)       = mean((Y_test - Y_est).^2);
    catch
        E_MSE(c1)       = 100;
    end
end

cost    = mean(E_MSE);

end




