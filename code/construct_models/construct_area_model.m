function objective_model = construct_area_model(x_input, y_area, HYPE)


if HYPE
    load('memory_project/results/hyperprior/area_hyp_data.mat');
    objective_model     = construct_hyperprior_model(x_input,y_area, hyp);
else
    objective_model     = construct_hyperprior_model(x_input,y_area);
    
end

end

