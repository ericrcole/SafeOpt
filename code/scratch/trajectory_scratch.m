data_path       = '/Users/mconn24/Box Sync/papers/2019_12_31_paper_safe_optimization/memory_data/ARN083_t.xlsx';
data_table      = readtable(data_path);
X_v             = data_table.voltage_new(2:end);
Y_ds            = data_table.DS(2:end);
close all
input_space     = linspace(0,4,100)';
for c1 = 2:12;size(X_v,1)
    
    gp_model = gp_object();
    gp_model.initialize_data(X_v(1:c1), Y_ds(1:c1)*X_v(c1))
    
    x_max(c1)= gp_model.discrete_extrema(input_space);
    
end

hold on
plot(X_v(1:12))
plot(x_max)