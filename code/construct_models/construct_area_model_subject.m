function objective_model = construct_area_model_subject(subject_id, HYPE)

data_table          = readtable('memory_project/data/processed_data/1D_amp_optimization_data/memory_data_all.xlsx');

subject_idx         = data_table.animal_id == subject_id;
x_input             = data_table.amplitude(subject_idx);
y_ds                = data_table.discriminant_score_b(subject_idx);
y_area              = x_input .* y_ds;

objective_model     = construct_area_model(x_input, y_area, HYPE);

end

