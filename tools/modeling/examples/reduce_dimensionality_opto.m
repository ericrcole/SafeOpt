load('/Users/mconn24/repositories/optogenetic_optimization_project/data/in_silico_data/modeled_data/gamma_3D/R3_gamma_3D.mat')

%% Amplitude
gp_amplitude = gp_object;
gp_amplitude.initialize_data(gp_model.x_data(:,1), gp_model.y_data)
gp_amplitude.plot_mean

%% Frequency
gp_frequency = gp_object;
gp_frequency.initialize_data(gp_model.x_data(:,1), gp_model.y_data)
gp_frequency.plot_mean

%% Amplitude x Frequency
gp_2d = gp_object;
gp_2d.initialize_data(gp_model.x_data(:,[1 2]), gp_model.y_data)
gp_2d.plot_mean
