% Subjects

% Old rats
% ARN052
% ARN053
% ARN055
% ARN056

% New rats
% ARN081
% ARN082
% ARN083
close all
data_dir        = '/Users/ERCOLE/Downloads/memory_project/data/raw_data/1D_amplitude';
data_path       = [data_dir 'raw_data/1D_amplitude/memory_data_2020_01_31.xlsx'];
data_table      = readtable(data_path);

subject_ids     = unique(data_table.animal_id);

for c1 = 1:3;size(subject_ids,1)
    
    subject_idx     = data_table.animal_id == subject_ids(c1);
    
    X               = data_table.amplitude(subject_idx);
    Y               = data_table.discriminant_score_b(subject_idx);
    
%     if c1 == 2
%        X = [X; 5];
%        Y = [Y; -.2];
%     end
%     
%     X = [X; 6; 7];
%     Y = [Y; -.3; -.3];
    
    ds_model        = gp_object;
    ds_model.initialize_data(X,Y,0,7);
    ds_model.minimize(1)
    figure
    subplot(2,1,1)
    hold on
    ds_model.plot_standard_deviation
    ds_model.plot_mean
    ds_model.plot_data
    ylim([-1 1])
    xlim([0 4])
    ylabel('DS')
    set(gca, 'FontSize', 14)
        xlabel('Voltage')

    subplot(2,1,2)
    input_space         = linspace(0,7,100)';
    [ds_mean, ds_std]   = ds_model.predict(input_space);
    da_mean             = ds_mean .* input_space;
    plot(input_space, da_mean)
    
    ds_models(c1) = ds_model;
  	xlim([0 4])

    ylabel('DA')
    set(gca, 'FontSize', 14)
    xlabel('Voltage')
end
%%
a = linspace(0,10,100);
b = linspace(0,10,100);
c = linspace(0,10,100);

input_space = combvec(a, b, c)';

a       = input_space(:,1);
b       = input_space(:,2);
c       = input_space(:,3);

ds1     = (a+b-c)./(a+b+c);
ds5     = ((a+b)/2-c)./((a+b)/2+c);

scatter(ds5,ds1)


