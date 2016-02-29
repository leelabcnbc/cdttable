function [ preprocessed_result ] = preprocessing_func( NEV_filename, preprocessing_params_path, template_path, CTX_filename )
%PREPROCESSING_FUNC Summary of this function goes here
%   Detailed explanation goes here

import nevreader.read_preprocessing_params
import nevreader.fix_NEV_CTX
import nevreader.add_rm_dependency
add_rm_dependency('add');
if nargin < 4 || isempty(CTX_filename)
    CTX_filename = [];
end

[ preprocessing_params, isValid ] = read_preprocessing_params(preprocessing_params_path, template_path);
assert(isValid);

% then read NEV codes and times.
% TODO: handle empty CTX_name

[NEV_code, NEV_time, ~, NEV_struct]=...
    fix_NEV_CTX(NEV_filename, preprocessing_params.get('fix_nev'), ...
    preprocessing_params.get('trial_template'), CTX_filename, ...
    preprocessing_params.get('fix_nev_throw_high_byte'));

% then get spiking info.
%% collect all useful electrode/unit combinations.

spikeElecUnit = [NEV_struct.Data.Spikes.Electrode(:), ...
    NEV_struct.Data.Spikes.Unit(:)];
spikePruneIdx = false(numel(NEV_struct.Data.Spikes.Electrode),1);

if preprocessing_params.get('spike_no_secondary_unit')
    spikePruneIdx( (spikeElecUnit(:,2)>1) & (spikeElecUnit(:,2)<255) ) = true;
end

if preprocessing_params.get('spike_no_255_unit')
    spikePruneIdx(spikeElecUnit(:,2)==255) = true;
end

if preprocessing_params.get('spike_no_0_unit')
    spikePruneIdx(spikeElecUnit(:,2)==0) = true;
end 
spikeElecUnit = spikeElecUnit(~spikePruneIdx,:); % keep non pruned spikes.
% elecUnitMap = ... % elecUnitMap is all maps not combined.
%     unique(spikeElecUnit,'rows'); 


%% get all spike times.
TimeStamps=double(NEV_struct.Data.Spikes.TimeStamp(:))./double(NEV_struct.MetaTags.TimeRes);
assert(numel(TimeStamps) == numel(spikePruneIdx)); % thus, we throw away a lot of spikes.
assert(NEV_struct.MetaTags.TimeRes==30000);
TimeStamps = TimeStamps(~spikePruneIdx);
assert(numel(TimeStamps) == size(spikeElecUnit,1));


% construct preprocessed result.
preprocessed_result = struct();
preprocessed_result.event_codes = NEV_code;
preprocessed_result.event_times = NEV_time;
preprocessed_result.spike_times = TimeStamps;
preprocessed_result.spike_locations = spikeElecUnit;

add_rm_dependency('rm');
end

