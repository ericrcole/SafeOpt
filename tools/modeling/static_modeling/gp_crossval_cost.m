function cost = gp_crossval_cost(P, X, Y)

cv_size     = 5;
indices     = crossvalind('Kfold', size(X,1), cv_size);

for c1 = 1:cv_size
    
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
    gp_model.hyperparameters.cov = P;

    %     gp_model.hyperparameters.cov = [-42.2821    8.4051   -7.5837];
    
    gp_model.hyperparameters.cov = P(1:2)';
    
    try
        [Y_est, Y_std]  = gp_model.predict(X_test);
        
        %         NMSE(c1)    = mean((Y_test - Y_est).^2)/var(Y);
        E_MSE(c1)     = mean((Y_test - Y_est).^2);
        %         U_MSE(c1)     = mean((mean(Y_std) - std(Y_test)).^2);    
  
    try
        [Y_est, Y_std]  = gp_model.predict(X_test);
   
        E_MSE(c1)     = mean((Y_test - Y_est).^2);
    catch
        E_MSE(c1)    = 100;
    end
end

cost    = mean(E_MSE);

end




