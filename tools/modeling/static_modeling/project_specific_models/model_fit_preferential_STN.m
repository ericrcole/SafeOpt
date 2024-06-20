f_bands         = 4:10; % Gamma

subject         = 1:3;

stim_phase      = 'delta';
channels        = 1:16;
intensity       = 50;
pulse_width     = [];
frequency       = [];

RESCALE         = 0;

load('data/processed_data/optogenetic_data/laxpati_2014/hSynChR2_PSD_COH_W20_Ch1-16_1-100Hz_1Hzbin.mat');

% Filter biomarkers
f_band_pre          = PSDall(:,1,channels,f_bands);
biomarker_pre       = sum(f_band_pre,4);        % Sum of frequencies
biomarker_pre       = mean(biomarker_pre,3);    % Mean across channels
biomarker_pre       = squeeze(biomarker_pre);

f_band_stim         = PSDall(:,2,channels,f_bands);
biomarker_stim      = sum(f_band_stim,4);       % Sum of frequencies
biomarker_stim      = mean(biomarker_stim,3);   % Mean across channels
biomarker_stim      = squeeze(biomarker_stim);

biomarker_delta     = biomarker_stim - biomarker_pre;

for c1 = 1:size(subject,2)
    % start filter idx to true
    idx             = true(size(PSDall,1),1);

    % filter params
    if ~isempty(intensity)
        idx         = idx & stimtable(:,1) == intensity;
    end

    if ~isempty(frequency)        
        idx         = idx & stimtable(:,2) == frequency;
    end

    if ~isempty(pulse_width)
        idx         = idx & stimtable(:,3) == pulse_width;    
    end

    switch stim_phase
        case 'pre'
            Y = biomarker_pre;
        case 'post'
            Y = biomarker_stim;
        case 'delta'
            Y = biomarker_delta;
    end

    % Filter NaN
    idx             = idx & ~isnan(Y);

    % filter subject
    idx             = idx & stimtable(:,4) == subject(c1);

    % Finalize dataset
    X   = stimtable(:,1:3);
    X   = X(idx,:);
    Y   = Y(idx);

    % Parameters
    controlled_params       = std(X) == 0;
    X(:,controlled_params)  = [];


    %%
    gp_model    = gp_object();
    gp_model.initialize_data(X,Y);
    gp_model.minimize(10);

    %% Re-scale y-data
    if RESCALE
        [~, y_max, ~, y_min]        = gp_model.discrete_extrema(2);
        y_norm                      = linear_normalize_X(gp_model.y_data, y_min, y_max);
        gp_model.y_data             = y_norm;
    end

    % Create meta data structure
    model_metadata.channel      = channels;
    model_metadata.stim_phase   = stim_phase;
    model_metadata.f_band       = f_bands;
    model_metadata.subject      = sprintf('R%d', subject);
    model_metadata.uncertainty  = 'homoscedastic';

    save_dir                    = 'data/modeled_data/optogenetic/theta_2D/';
    model_name                  = sprintf('R%d_delta_theta_2D.mat', subject(c1));
    save_path                   = [save_dir model_name];
    save(save_path, 'model_metadata', 'gp_model');
end
