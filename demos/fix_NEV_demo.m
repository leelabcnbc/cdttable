function fix_NEV_demo(fullFlag)
% FIX_NEV_DEMO ...
%
%   a demo for fixing NEV files in the fix_NEV project.
%
% Yimeng Zhang
% Computer Science Department, Carnegie Mellon University
% zym1010@gmail.com

%% DATE      : 22-Jul-2015 10:00:21 $
%% DEVELOPED : 8.3.0.532 (R2014a)
%% FILENAME  : fix_NEV_demo.m

if nargin < 1 || isempty(fullFlag)
    fullFlag = false; % use full to get a more complete test. takes longer.
end

% basePath = '/vagrant_data'; % for Vagrant machine.
% % this varies from machine to machine.
basePath = fullfile(root_dir(),'demos','fix_NEV_demo_data');

refResult1 = load(fullfile('fix_NEV_demo_results','NEV_CTX_result_all_new.mat'));
refResult2 = load(fullfile('fix_NEV_demo_results','NEV_CTX_result_all_add_new.mat'));


if fullFlag
    info_set = file_info_set(basePath);
    
    [NEV_codes_new_array,NEV_times_new_array] = get_codes_and_times(info_set);
    
    codes_flat_new =cell2mat(cellfun(@cell2mat,NEV_codes_new_array,'UniformOutput',false ));
    codes_flat_old =cell2mat(cellfun(@cell2mat,refResult1.NEV_codes_new_array,'UniformOutput',false ));
    times_flat_new =cell2mat(cellfun(@cell2mat,NEV_times_new_array,'UniformOutput',false ));
    times_flat_old =cell2mat(cellfun(@cell2mat,refResult1.NEV_times_new_array,'UniformOutput',false ));
    
    codeDiff = max(abs(codes_flat_new(:)-codes_flat_old(:)));
    timeDiff = max(abs(times_flat_new(:)-times_flat_old(:))); % I don't use isequal because I guess some roundoffs in time computation can be there.
    
    fprintf('for set 1, code difference: %f, time difference: %f\n',...
        codeDiff,timeDiff);
    assert(codeDiff == 0);
    assert(timeDiff < 1e-3);
end

info_set = file_info_set_add(basePath);
[NEV_codes_new_array,NEV_times_new_array] = get_codes_and_times(info_set);

% unwrap for easier comparison.
codes_flat_new =cell2mat(cellfun(@cell2mat,NEV_codes_new_array,'UniformOutput',false ));
codes_flat_old =cell2mat(cellfun(@cell2mat,refResult2.NEV_codes_new_array,'UniformOutput',false ));
times_flat_new =cell2mat(cellfun(@cell2mat,NEV_times_new_array,'UniformOutput',false ));
times_flat_old =cell2mat(cellfun(@cell2mat,refResult2.NEV_times_new_array,'UniformOutput',false ));



codeDiff = max(abs(codes_flat_new(:)-codes_flat_old(:)));
timeDiff = max(abs(times_flat_new(:)-times_flat_old(:))); % I don't use isequal because I guess some roundoffs in time computation can be there.

fprintf('for set 2, code difference: %f, time difference: %f\n',...
    codeDiff,timeDiff);
assert(codeDiff == 0);
assert(timeDiff < 1e-3);


end

function [NEV_codes_new_array,NEV_times_new_array] = get_codes_and_times(info_set)

%NEV_codes_new_array = cell(length(info_set),1);
%NEV_times_new_array = cell(length(info_set),1);
nevreader.add_rm_dependency('add');
templateArray = cell(length(info_set),1);
NEVNameArray = cellfun(@(x) x{1}, info_set, 'UniformOutput',false);
CTXNameArray = cellfun(@(x) x{4}, info_set, 'UniformOutput',false);
trueArray = repmat({true},length(info_set),1);


for i = 1:length(info_set)
    assert(exist(info_set{i}{1},'file')==2);
    fprintf('fixing file %d\n', i);
    [trial_template_this, isValid] = nevreader.read_and_validate_json(...
        fullfile(nevreader.root_dir(),'demo_trial_templates',...
        tm_cnd_pair_to_prototxt(info_set{i}{2}, info_set{i}{3})),...
        'nev_rewarded_trial_template_schema.json');
    assert(isValid);
    templateArray{i} = trial_template_this;
end
[NEV_codes_new_array,NEV_times_new_array] = cellfun(@nevreader.fix_NEV_CTX,...
    NEVNameArray,trueArray,templateArray,CTXNameArray,trueArray,'UniformOutput',false);

nevreader.add_rm_dependency('rm');

end


function [ NameSet ] = file_info_set(basePath)
%FILENAME_SET For each experiment, list its NEV and CORTEX filenames.
%   Detailed explanation goes here
% note that the CORTEX file names are synthesized, and may not exist at
% all.
% Yimeng Zhang, 09/18/2013
% Pittsburgh, PA, USA

NEV_data_path = [basePath filesep 'real_data_NEV' filesep];
CORTEX_data_path = [basePath filesep 'real_data_CORTEX' filesep];

NameSet = {
    {'v1_2012_0913_004.nev'; '3ec_or.tm'; 'edge_or0.cnd';'GA091312.4';};
    {'v1_2012_0913_005.nev'; '3ec_or.tm'; 'edge_or0.cnd';'GA091312.5';};
    {'v1_2012_0914_003.nev'; '3ec_or.tm'; 'edge_or0.cnd';'GA091412.3';};
    {'v1_2012_0927_001.nev'; '3ec_or.tm'; 'edge_cal.cnd';'GA092712.1';};
    {'v1_2012_0927_008.nev'; '3ec_or.tm'; 'edge_or0.cnd';'GA092712.8';};
    % don't find them on leelab
    % {'v1_2012_1013_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101312.4';};
    % {'v1_2012_1013_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101312.4';};
    % {'v1_2012_1013_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101312.4';};
    {'v1_2012_1012_005.nev'; '3ec_or.tm'; 'gratings.cnd';'GA101212.5';};
    {'v1_2012_1012_006.nev'; '3ec_or.tm'; 'images.cnd';'GA101212.6';};
    {'v1_2012_1012_009.nev'; '3ec_or.tm'; 'gratings.cnd';'GA101212.9';};
    {'v1_2012_1012_010.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101212.10';};
    {'v1_2012_1012_011.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101212.11';};
    {'v1_2012_1018_005.nev'; '3ec_or.tm'; 'images.cnd';'GA101812.5';};
    {'v1_2012_1018_006.nev'; '3ec_or.tm'; 'images.cnd';'GA101812.6';};
    {'v1_2012_1018_007.nev'; '3ec_or.tm'; 'images.cnd';'GA101812.7';};
    {'v1_2012_1018_008.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101812.8';};
    {'v1_2012_1018_009.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101812.9';};
    {'v1_2012_1019_002.nev'; '3ec_or.tm'; 'images.cnd';'GA101912.2';};
    {'v1_2012_1019_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101912.3';};
    {'v1_2012_1019_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101912.4';};
    {'v1_2012_1019_005.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101912.5';};
    {'v1_2012_1021_001.nev'; '3ec_or.tm'; 'images.cnd';'GA102112.1';};
    {'v1_2012_1021_002.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA102112.2';};
    {'v1_2012_1021_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA102112.3';};
    {'v1_2012_1021_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA102112.4';};
    {'v1_2012_1022_001.nev'; '3ec_or.tm'; 'images.cnd';'GA102212.1';};
    {'v1_2012_1022_002.nev'; '3ec_or.tm'; 'gratings.cnd';'GA102212.2';};
    {'v1_2012_1022_003.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102212.3';};
    {'v1_2012_1022_004.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102212.4';};
    {'v1_2012_1023_001.nev'; '3ec_or.tm'; 'images.cnd';'GA102312.1';};
    {'v1_2012_1023_002.nev'; '3ec_or.tm'; 'gratings.cnd';'GA102312.2';};
    {'v1_2012_1023_006.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102312.6';};
    {'v1_2012_1023_007.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102312.7';};
    {'v1_2012_1024_002.nev'; '3ec_or.tm'; 'images.cnd';'GA102412.2';};
    {'v1_2012_1024_003.nev'; '3ec_or.tm'; 'gratings.cnd';'GA102412.3';};
    {'v1_2012_1024_004.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102412.4';};
    {'v1_2012_1024_005.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102412.5';};
    {'v1_2012_1025_001.nev'; '3ec_or.tm'; 'images.cnd';'GA102512.1';};
    {'v1_2012_1025_002.nev'; '3ec_or.tm'; 'gratings.cnd';'GA102512.2';};
    {'v1_2012_1025_003.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102512.3';};
    {'v1_2012_1025_004.nev'; '3ec.tm'; 'edge_pos.cnd';'GA102512.4';};
    {'v1_2012_1026_001.nev'; '3ec_or.tm'; 'images.cnd';'GA102612.1';};
    {'v1_2012_1026_002.nev'; '3ec_or.tm'; 'gratings.cnd';'GA102612.2';};
    {'v1_2012_1026_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA102612.3';};
    {'v1_2012_1026_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA102612.4';};
    {'v1_2012_1026_005.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA102612.5';};
    {'v1_2012_1031_001.nev'; '3ec_or.tm'; 'images.cnd';'GA103112.1';};
    {'v1_2012_1031_002.nev'; '3ec_or.tm'; 'gratings.cnd';'GA103112.2';};
    {'v1_2012_1031_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA103112.3';};
    {'v1_2012_1031_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA103112.4';};
    {'v1_2012_1101_001.nev'; '3ec_or.tm'; 'images.cnd';'GA110112.1';};
    {'v1_2012_1101_002.nev'; '3ec_or.tm'; 'gratings.cnd';'GA110112.2';};
    {'v1_2012_1101_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA110112.3';};
    {'v1_2012_1101_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA110112.3';};
    {'v1_2012_1105_001.nev'; '3ec_or.tm'; 'images.cnd';'GA110512.1';};
    {'v1_2012_1105_002.nev'; '3ec_or.tm'; 'gratings.cnd';'GA110512.2';};
    {'v1_2012_1105_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA110512.3';};
    {'v1_2012_1105_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA110512.4';};
    {'v1_2012_1105_005.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA110512.5';};
    {'v1_2012_1106_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA110612.1';};
    {'v1_2012_1106_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA110612.2';};
    {'v1_2012_1106_003.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA110612.3';};
    {'v1_2012_1107_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA110712.1';};
    {'v1_2012_1107_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA110712.2';};
    {'v1_2012_1107_003.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA110712.3';};
    {'v1_2012_1107_004.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA110712.4';};
    {'v1_2012_1108_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA110812.1';};
    {'v1_2012_1108_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA110812.2';};
    {'v1_2012_1108_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA110812.3';};
    {'v1_2012_1108_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA110812.3';};
    {'v1_2012_1108_004.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA110812.4';};
    {'v1_2012_1108_005.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA110812.5';};
    {'v1_2012_1109_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA110912.1';};
    {'v1_2012_1109_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA110912.2';};
    {'v1_2012_1109_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA110912.3';};
    {'v1_2012_1109_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA110912.3';};
    {'v1_2012_1115_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA111512.1';};
    {'v1_2012_1115_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA111512.2';};
    {'v1_2012_1115_003.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA111512.3';};
    {'v1_2012_1115_004.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA111512.4';};
    {'v1_2012_1120_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA112012.1';};
    {'v1_2012_1120_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA112012.2';};
    {'v1_2012_1120_003.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA112012.3';};
    {'v1_2012_1120_004.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA112012.4';};
    {'v1_2012_1121_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA112112.1';};
    {'v1_2012_1121_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA112112.2';};
    {'v1_2012_1121_003.nev'; '3ec_ora.tm'; 'edge_or.cnd';'GA112112.3';};
    {'v1_2012_1121_004.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA112112.4';};
    {'v1_2012_1127_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA112712.1';};
    {'v1_2012_1127_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA112712.2';};
    {'v1_2012_1127_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA112712.3';};
    {'v1_2012_1127_004.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA112712.4';};
    {'v1_2012_1128_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA112812.1';};
    {'v1_2012_1128_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA112812.2';};
    {'v1_2012_1128_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA112812.3';};
    {'v1_2012_1128_004.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA112812.4';};
    % don't find them on leelab
    % {'v1_2012_1130_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA113012.1';};
    % {'v1_2012_1130_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA113012.2';};
    % {'v1_2012_1130_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA113012.3';};
    % {'v1_2012_1130_004.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA113012.4';};
    {'v1_2012_1206_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA120612.1';};
    {'v1_2012_1206_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA120612.2';};
    {'v1_2012_1206_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA120612.3';};
    {'v1_2012_1217_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA121712.1';};
    {'v1_2012_1217_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA121712.2';};
    {'v1_2012_1217_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA121712.3';};
    {'v1_2012_1218_001.nev'; '3ec_ora.tm'; 'images.cnd';'GA121812.1';};
    {'v1_2012_1218_002.nev'; '3ec_ora.tm'; 'gratings.cnd';'GA121812.2';};
    {'v1_2012_1218_003.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA121812.3';};
    };

for i = 1:length(NameSet)
    NameSet{i}{1} = [NEV_data_path NameSet{i}{1}];
    NameSet{i}{4} = [CORTEX_data_path NameSet{i}{4}];
end

end



function [ NameSet ] = file_info_set_add(basePath)
%FILENAME_SET For each experiment, list its NEV and CORTEX filenames.
%   Detailed explanation goes here
% note that the CORTEX file names are synthesized, and may not exist at
% all.
% Yimeng Zhang, 09/18/2013
% Pittsburgh, PA, USA

NEV_data_path = [basePath filesep 'real_data_NEV' filesep];
CORTEX_data_path = [basePath filesep 'real_data_CORTEX' filesep];

NameSet = {
    {'v1_2012_1011_002.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101112.2';};
    {'v1_2012_1011_003.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101112.3';};
    {'v1_2012_1011_004.nev'; '3ec_or.tm'; 'edge_or.cnd';'GA101112.4';};
    {'v1_2012_1109_004.nev'; '3ec_a.tm'; 'edge_pos.cnd';'GA110912.4';};
    };

for i = 1:length(NameSet)
    NameSet{i}{1} = [NEV_data_path NameSet{i}{1}];
    NameSet{i}{4} = [CORTEX_data_path NameSet{i}{4}];
end

end




% Created with NEWFCN.m by Frank González-Morphy
% Contact...: frank.gonzalez-morphy@mathworks.de
% ===== EOF ====== [fix_NEV_demo.m] ======
