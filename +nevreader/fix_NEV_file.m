function [NEV_codes_new, NEV_times_new, rewarded_trials, ...
    NEV_codes_old, NEV_times_old, NEV_split] = fix_NEV_file(...
    NEV_file_name, fixing, trial_template, throw_high_byte)
% FIX_NEV_FILE fix NEV file based on a template.
%  
%   ... 
%
% Yimeng Zhang
% Computer Science Department, Carnegie Mellon University
% zym1010@gmail.com

%% DATE      : 21-Jul-2015 21:42:48 $ 
%% DEVELOPED : 8.3.0.532 (R2014a) 
%% FILENAME  : fix_NEV_file.m 

import nevreader.split_trial_NEV
import nevreader.fix_NEV_trial_TM

%% read old NEV codes and times.

% should add path of NPMK, and then rmpath.
addpath(genpath(NPMK_dir()));
NEV_NMPK=openNEV(NEV_file_name,'nosave','nomat','noread');
rmpath(genpath(NPMK_dir()));
NEV_codes_old=double(NEV_NMPK.Data.SerialDigitalIO.UnparsedData(1:end));%codes
NEV_times_old=double(NEV_NMPK.Data.SerialDigitalIO.TimeStampSec(1:end));%time stamps of codes

NEV_codes_old = NEV_codes_old(:);
NEV_times_old = NEV_times_old(:);

if throw_high_byte % only read low byte
    NEV_codes_old = rem(NEV_codes_old,256);
end

assert(numel(NEV_codes_old)==numel(NEV_times_old));

%% start, stop, reward codes for splitting and getting good trials.
startcode = double(trial_template.get('start_code'));
stopcode = double(trial_template.get('stop_code'));
rewardcode = double(trial_template.get('reward_code'));

%% use start/stop codes to split the whole code sequence into parts.
NEV_split = split_trial_NEV(NEV_codes_old, startcode, stopcode);

%% arrays holding fixed trials, as well as indices.
NEV_codes_new = {};
NEV_times_new = {};
rewarded_trials = [];

for i = 1:length(NEV_split)
    %fprintf('fixing trial %d...\n',i);
    % fetch next trial
    nev_trial = ... % nev_trial is a Nx2 matrix, first column code, second column time.
        [NEV_codes_old(NEV_split{i}.start:NEV_split{i}.end), ...
        NEV_times_old(NEV_split{i}.start:NEV_split{i}.end)];
    % it's a rewarded trial... let's use fix_NEV_trial_TM!
    if ismember(rewardcode, nev_trial(:,1))
        %fprintf('fixing a perhaps good trial...\n');
        fixable = true; % is this indeed a good trial that can be fixed.
        if fixing
            [nev_trial_new, fixable] = fix_NEV_trial_TM(nev_trial, trial_template.get('codes'));
        end
       
        if fixable
            rewarded_trials(end+1) = i;
            % put them back as cells... or I need some other formats?
            if fixing % use the fixed trials.
                NEV_codes_new{end+1} = nev_trial_new(:,1);
                NEV_times_new{end+1} = nev_trial_new(:,2);
            else % just assume old trials are good enough.
                NEV_codes_new{end+1} = nev_trial(:,1);
                NEV_times_new{end+1} = nev_trial(:,2);
            end
        end
    end
end

NEV_codes_new = NEV_codes_new(:);
NEV_times_new = NEV_times_new(:);
rewarded_trials = rewarded_trials(:);

fprintf('in total, %d rewarded trials from NEV\n', length(rewarded_trials));

end








% Created with NEWFCN.m by Frank González-Morphy 
% Contact...: frank.gonzalez-morphy@mathworks.de  
% ===== EOF ====== [fix_NEV_file.m] ======  
