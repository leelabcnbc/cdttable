function [NEV_codes_new, NEV_times_new, debugging_info, NEV_NMPK] = fix_NEV_CTX(NEV_file_name, ...
    fixing, trial_template, CTX_file_name, throw_high_byte)
% FIX_NEV_CTX master function to read good trials from NEV file, with CTX file's help if possible.
%
%   NEV_file_name: name of NEV
%   fixing: do we run the fix routines, or just assume everything is
%   fine...
%   trial_template a protobuf class specifying the good trial template.
%   CTX_file_name: name of CTX, leave it empty if you don't have it. can be
%   used for further debugging.
%   throw_high_byte: throw higher byte when reading codes (each code is a 2
%   byte number, and only keep the lower byte).
%
% Yimeng Zhang
% Computer Science Department, Carnegie Mellon University
% zym1010@gmail.com

%% DATE      : 21-Jul-2015 21:19:27 $
%% DEVELOPED : 8.3.0.532 (R2014a)
%% FILENAME  : fix_NEV_CTX.m

import nevreader.fix_NEV_file
import nevreader.fix_CTX_file

if nargin < 5 || isempty(throw_high_byte)
    throw_high_byte = true;
end

debugging_info = struct();

fixed_NEV_trials_by_CTX_array = []; % the indicies of trials that are additionally fixed by CTX.
errors_fixed_by_CTX = 0; % number of trials additionally fixed by CTX.

% NEV_rewarded_trials is the indices of rewarded trials.
[NEV_codes_new, NEV_times_new, NEV_rewarded_trials, ...
    ~, ~, ~, NEV_NMPK] = fix_NEV_file(NEV_file_name, fixing, trial_template, throw_high_byte);

debugging_info.NEV_rewarded_trials = NEV_rewarded_trials;

if fixing && exist(CTX_file_name,'file') == 2 % use CTX as additional source of confidence
    [CTX_codes_new, ~, CORTEX_rewarded_trials]=fix_CTX_file(CTX_file_name, trial_template);
    
    extra_CORTEX_trials = setdiff(CORTEX_rewarded_trials, NEV_rewarded_trials);
    if ~isempty(extra_CORTEX_trials)
        fprintf('for file, we have extra Cortex trials.\n');
        disp(extra_CORTEX_trials);
    end
    debugging_info.CORTEX_rewarded_trials = CORTEX_rewarded_trials;
    debugging_info.extra_CORTEX_trials = extra_CORTEX_trials;
    
    % This merging assumes that the indices of trials are consistent for
    % two files. That is, trial x in NEV should correspond to trial x in
    % CTX.
    useful_CORTEX_trials_for_NEV = intersect(CORTEX_rewarded_trials, NEV_rewarded_trials);
    unchecked_NEV_trials = setdiff(NEV_rewarded_trials, CORTEX_rewarded_trials);
    debugging_info.unchecked_NEV_trials = unchecked_NEV_trials;
    debugging_info.useful_CORTEX_trials_for_NEV = useful_CORTEX_trials_for_NEV;
    
    fprintf('merging trials for file\n');
    
    for rewarded_trial_idx = useful_CORTEX_trials_for_NEV(:)' % for loop over every trial in both NEV and CTX.
        NEV_code = NEV_codes_new{NEV_rewarded_trials==rewarded_trial_idx};
        CORTEX_code = CTX_codes_new{CORTEX_rewarded_trials==rewarded_trial_idx};
        if ~isequal(NEV_code,CORTEX_code)
            fprintf('for trial %d, NEV and CORTEX are different\n', rewarded_trial_idx);
            
            fixed_NEV_trials_by_CTX_array(end+1) = rewarded_trial_idx;
            
            disp([CORTEX_code, NEV_code, CORTEX_code-NEV_code]);
            errors_fixed_by_CTX = errors_fixed_by_CTX+1;
            
            fprintf('Replacing NEV codes with Cortex ones...\n');
            NEV_codes_new{NEV_rewarded_trials==rewarded_trial_idx} = CORTEX_code;
            % Notice that I only changed the code, not time.
            % this should not affect much, since the changed codes are usually not critical for trial extraction.
        end
    end
    debugging_info.fixed_NEV_trials_array = fixed_NEV_trials_by_CTX_array;
    debugging_info.errors_fixed_by_CTX = errors_fixed_by_CTX;
end

end








% Created with NEWFCN.m by Frank González-Morphy
% Contact...: frank.gonzalez-morphy@mathworks.de
% ===== EOF ====== [fix_NEV_CTX.m] ======
