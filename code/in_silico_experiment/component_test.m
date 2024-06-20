
beta                    = 1;
eta                     = .1;
subject_idx             = [52 55 56];
simulation_data_dir     = 'in_silico_optimization/data/simulation_data/memory/algorithm_components/';

params                  = [beta eta];

for c1 = 1:size(subject_idx,2)
    ds_model = model_fit_hippocampal_admes(subject_idx(c1));

    idx = 1; hyp(idx) = 0; safe(idx) = 0;
    [estimated_v_optimal(idx,:,:), estimated_area_optimal(idx,:,:), sample_v(idx,:,:), sample_area(idx,:,:)] = safe_opt(ds_model, params, hyp(idx), safe(idx));
     
    idx = 2; hyp(idx) = 1; safe(idx) = 0;
    [estimated_v_optimal(idx,:,:), estimated_area_optimal(idx,:,:), sample_v(idx,:,:), sample_area(idx,:,:)] = safe_opt(ds_model, params, hyp(idx), safe(idx));     
    
    idx = 3; hyp(idx) = 0; safe(idx) = 1;
    [estimated_v_optimal(idx,:,:), estimated_area_optimal(idx,:,:), sample_v(idx,:,:), sample_area(idx,:,:)] = safe_opt(ds_model, params, hyp(idx), safe(idx));
     
    idx = 4; hyp(idx) = 1; safe(idx) = 1;
    [estimated_v_optimal(idx,:,:), estimated_area_optimal(idx,:,:), sample_v(idx,:,:), sample_area(idx,:,:)] = safe_opt(ds_model, params, hyp(idx), safe(idx));
      
    sim_data_file_name      = sprintf('ARN0%d_simulation_results.mat', subject_idx(c1));
    simulation_data_path    = [simulation_data_dir sim_data_file_name];
    
    save(simulation_data_path, 'hyp', 'safe', 'estimated_v_optimal', 'estimated_area_optimal', 'sample_v', 'sample_area');
        
end

%%


%%
