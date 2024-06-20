function objective_model = construct_ds_model(x_input, y_ds, HYPE, alpha)

ds_model                = gp_object();

ds_model.initialize_data(x_input, y_ds, 0, 7);

if HYPE
    load('memory_project/results/hyperprior/ds_hyp_data_2020_02_02.mat');
    objective_model     = construct_hyperprior_model(x_input,y_ds, hyp, alpha);
else
    objective_model     = construct_hyperprior_model(x_input,y_ds);
    
end

end

