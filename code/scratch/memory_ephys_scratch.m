data_dir            = '/Users/mconn24/Dropbox/Extracted Data/ARN052/';


params.tapers       = [3 5];
params.Fs           = 2000;
params.fpass        = [4 55];

channel             = [4 1];

d                   = dir([data_dir 'C*']);

for c1 = 1:size(d,1)
    file_name = d(c1).name;
    f_token = split(file_name,'_');
    switch f_token{6}
        case 'pre4V.mat'
            condition(c1) = 2;
        case 'post4V.mat'
            condition(c1) = 4;
    	case 'presham.mat'
            condition(c1) = 1;
        case 'postsham.mat'
            condition(c1) = 3;
    end
%     load([data_dir file_name]);
    
%     data                    = lfp_data(channel(1),:) - lfp_data(channel(2),:);
%     [S{c1}, t{c1}, f{c1}]   = mtspecgramc(data, [3 3], params);
%     c1
end

%%
close all
p = [27,158,119
217,95,2
117,112,179
231,41,138]/255;


window = 20:20:100;
% yyaxis left
hold on
for c2 = 1:size(window,2)
    [~, time_start_idx] = min(abs(t{c1} - 1));
    [~, time_end_idx]   = min(abs(t{c1} - window(c2)));

    [~, band_start_idx] = min(abs(f{c1} - 16));
    [~, band_end_idx]   = min(abs(f{c1} - 30));

    for c1 = 1:size(S,2)
        S_trial         = S{c1};
        S_time          = S_trial(time_start_idx:time_end_idx,:);
        S_norm          = S_time ./ sum(S_time,2);
        
        power_time      = sum(S_norm(:,band_start_idx:band_end_idx),2); 
        power_mean(c1)  = median(power_time);
        
        if ds(c1) < 1.1
            if condition(c1) < 3
                scatter(power_mean(c1), ds(c1), 300, p(condition(c1),:), 'Marker','x')
            else
                scatter(power_mean(c1), ds(c1), 300, p(condition(c1),:), 'Marker','o')
            end
        end
    end

end

% plot(power_mean)
% 
% [a b] = corr(power_mean(ds < 1)', ds(ds<1))
% yyaxis right
% plot(ds)

%%


data_path{1}    = [data_dir 'CustomStimActiveX_DT1_031017_Block-28_ARN052_presham.mat'];
data_path{2}    = [data_dir 'CustomStimActiveX_DT1_031117_Block-44_ARN052_pre4V.mat'];

data_path{3}   = [data_dir 'CustomStimActiveX_DT1_031017_Block-30_ARN052_postsham.mat'];
data_path{4}   = [data_dir 'CustomStimActiveX_DT1_031117_Block-47_ARN052_post4V.mat'];



figure;
hold on

%%%%
subplot(2,2,1)
load(data_path{1})

data        = lfp_data(channel(1),:) - lfp_data(channel(2),:);
[S1, t, f]  = mtspecgramc(data, [1 1], params);
plot_matrix(S1, t, f)
caxis([-125 -95])

%%%%
subplot(2,2,2)
load(data_path{3})

data        = lfp_data(channel(1),:) - lfp_data(channel(2),:);
[S2, t, f]  = mtspecgramc(data, [1 1], params);
plot_matrix(S2, t, f)
caxis([-125 -95])

% S1_norm  = S1'./sum(S1');
% S2_norm  = S2'./sum(S2');
% 
% m   = mean(S2_norm-S1_norm,2);
% s   = std(S2_norm-S1_norm,[],2);
% se  = s / sqrt(size(S2_norm,2));
% ci  = se *1.96;
% 
% plot(f, [m m+ci m-ci])

%%%%%
subplot(2,2,3)
load(data_path{2})

data        = lfp_data(channel(1),:) - lfp_data(channel(2),:);
[S1, t, f]  = mtspecgramc(data, [1 1], params);
plot_matrix(S1, t, f)
caxis([-125 -95])

%%%%%
subplot(2,2,4)
load(data_path{4})

data        = lfp_data(channel(1),:) - lfp_data(channel(2),:);
[S1, t, f]  = mtspecgramc(data, [1 1], params);
plot_matrix(S1, t, f)
caxis([-125 -95])

%%
load(data_path{2})
[S1, t, f] = mtspecgramc(lfp_data(channel,:), [1 1], params);

load(data_path{4})
[S2, t, f] = mtspecgramc(lfp_data(channel,:), [1 1], params);

S1_norm  = S1'./sum(S1');
S2_norm  = S2'./sum(S2');

m = mean(S2_norm-S1_norm,2);
s = std(S2_norm-S1_norm,[],2);
se = s / sqrt(size(S2_norm,2));
ci = se * 1.96;

plot(f, [m m+ci m-ci])

%%

figure;
channel_1               = 1;
channel_2               = 8;
window_param            = [3 3];

subplot(1,2,1)
hold on
load(pre_sham_path{1})
[S,~,~,~,~,t,f] = cohgramc(lfp_data(channel_1,:)',lfp_data(channel_2,:)',window_param,params);
plot(f, mean(S))
% plot_matrix(S, t, f,  'n')

% subplot(2,2,2)
load(post_sham_path{1})
[S,~,~,~,~,t,f] = cohgramc(lfp_data(channel_1,:)',lfp_data(channel_2,:)',window_param,params);
plot(f, mean(S))
% plot_matrix(S, t, f,  'n')

subplot(1,2,2)
hold on
load(pre_stim_path{1})
[S,~,~,~,~,t,f] = cohgramc(lfp_data(channel_1,:)',lfp_data(channel_2,:)',window_param,params);
plot(f, mean(S))
% plot_matrix(S, t, f,  'n')

% subplot(2,2,4)
load(post_stim_path{1})
[S,~,~,~,~,t,f] = cohgramc(lfp_data(channel_1,:)',lfp_data(channel_2,:)',window_param,params);
plot(f, mean(S))
% plot_matrix(S, t, f,  'n')
