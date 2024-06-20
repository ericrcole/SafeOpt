function gp_model = model_fit_hippocampal_admes(subject_id)

data_table      = readtable('memory_project/data/processed_data/1D_amp_optimization_data/memory_data_all.xlsx');

subject_idx     = data_table.animal_id == subject_id;
x_input         = data_table.amplitude(subject_idx);
y_ds            = data_table.discriminant_score_b(subject_idx);

gp_model        = gp_object();
gp_model.initialize_data(x_input, y_ds, 0, 4);
gp_model.minimize(10);
                
end