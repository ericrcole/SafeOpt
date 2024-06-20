function objective_model = construct_ds_model_subject(subject_id, HYPE)
data_table          = readtable('memory_project/data/processed_data/1D_amp_optimization_data/memory_data_all.xlsx');

subject_idx         = data_table.animal_id == subject_id;
x_input             = data_table.amplitude(subject_idx);
y_ds                = data_table.discriminant_score_b(subject_idx);

objective_model     = construct_ds_model(x_input, y_ds, HYPE, 1);

end

