clear, close all

% get root dir & creat result folder
[rootDir,~,~] = fileparts(mfilename('fullpath'));

% load CDTTable
load(fullfile(rootDir, '..','import_NEV_demo_results/import_NEV_demo_result.mat'));
cdt = mergeFiles(CDTTables);  % merge cdt structures if the CDTTable contains several of them
clear CDTTables 

%%
sigma = 30;    % parameter for smoothing
cnd_range = [1 208; 209 416];

length_trail = 1600; % in ms
align_third = false;

%% %%%%%%%%%%%%%%%%%%%%%%
% if you want to align trails according to the third stimulus on
if align_third
    num_trails = size(cdt.starttime,1);
    shift_of_third = cdt.starttime(:,3)-1;
    Starttime = mat2cell(cdt.starttime,ones(num_trails,1),3);
    time_to_subtract = cellfun(@(y) y(1,3)-1,Starttime,'UniformOutput',false);
    disp(cdt.spikeTimes{1,1}{1,1});
    cdt.spikeTimes = cellfun(@(x,y) cellfun(@(z) z-y, x,'UniformOutput',false)  , cdt.spikeTimes, time_to_subtract,'UniformOutput',false);
    disp(cdt.spikeTimes{1,1}{1,1});
    disp(shift_of_third(1));
end

%%
recording_date = 'demo_date';
Neurons = get_good_channel_unit(recording_date);
num_neurons = size(Neurons,2);
num_cates = 2;

Spike_counts = zeros(length_trail,num_neurons,num_cates);
for ith_neuron = 1:num_neurons
    spikeTimesCollected = cellfun(@(x,y,z) y(x==Neurons(1,ith_neuron) & z==Neurons(2,ith_neuron)), ...
        cdt.spikeElectrode,cdt.spikeTimes,cdt.spikeUnit,'UniformOutput',false);
    
    figure
    for ith_cate = 1:size(cnd_range,1)
        spike_times = spikeTimesCollected( (cdt.condition >= cnd_range(ith_cate,1)) ...
            & (cdt.condition <= cnd_range(ith_cate,2)) );
        spike_times = vertcat(spike_times{:});
        
        if ~isempty(spike_times),
            psth = get_psth(spike_times,length_trail,sigma);
            Spike_counts(:,ith_neuron,ith_cate) = psth;
            switch ith_cate
                case 1
                    plot(psth,'r','LineWidth',1)
                case 2
                    plot(psth,'b','LineWidth',1)
            end
            hold on
        end     
    end
    title(sprintf('PSTH: channel %d, unit %d',Neurons(1,ith_neuron),Neurons(2,ith_neuron)),...
        'FontSize',18)
end


%% Average responses
Ave_spike_counts = squeeze(sum(Spike_counts,2))/num_neurons;
psth_max_height =max(max(Ave_spike_counts));
figure
plot(Ave_spike_counts(:,1),'r','LineWidth',3)
hold on
plot(Ave_spike_counts(:,2),'b','LineWidth',3)
hold on
title(sprintf('Average PSTH: %d neurons, %d stimuli',num_neurons,104),'FontSize',18)
 




