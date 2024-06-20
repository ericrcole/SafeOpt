function construct_dynamic_model()

subject_id      = {'ARN052', 'ARN053', 'ARN055', 'ARN056'};

root_dir        = '/Users/mconnolly/Intelligent Control Repository/';
processed_dir   = [root_dir 'workspace/processed_data/grid_search_processed/'];
save_dir        = [root_dir 'test_code/optimization_paper/models/'];

feature_channel = [2 0 4 1];
feature_range   = 17:18;

subject_idx     = [1 3 4];

for c1 = 1:size(subject_idx,2)
    
    
    file_path       = [processed_dir subject_id{subject_idx(c1)} '/' subject_id{subject_idx(c1)} '_processed' ];
    save_path       = [save_dir subject_id{subject_idx(c1)} '_dynamic_simulation_model'];
    biomarker_data  = load(file_path);   
    
    channel_idx     = feature_groups('channel', feature_channel(subject_idx(c1)));
    feature_idx     = channel_idx(feature_range);
    pre_biomarker   = sum(biomarker_data.features_pre(:,feature_idx),2);
    post_biomarker  = sum(biomarker_data.features_post(:,feature_idx),2);
    
    stim_labels     = biomarker_data.stim_labels(:,1:2);

    u_x_t           = [pre_biomarker stim_labels];
    dx              = post_biomarker;
    
    gp_sim          = simulation_gp();
    gp_sim.initialize_data(u_x_t, dx, [15 1], [120 4]);
    
    save(save_path, 'gp_sim', 'stim_labels', 'pre_biomarker', 'post_biomarker' )
end

