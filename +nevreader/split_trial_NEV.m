function [NEV_trials] = split_trial_NEV(  nev_codes, starting_code, ending_code )
% SPLIT_TRIAL_NEV ...
%
%   ...
%
% Yimeng Zhang
% Computer Science Department, Carnegie Mellon University
% zym1010@gmail.com

%% DATE      : 21-Jul-2015 22:03:32 $
%% DEVELOPED : 8.3.0.532 (R2014a)
%% FILENAME  : split_trial_NEV.m

% now, we temporarily assume starting_codes and ending codes are scalars.

% next we have the problem of how to identify boundaries between trials.
% now I find trials by first finding a starting code and continue until I
% find a ending code.

% Yimeng Zhang, 09/18/2013
% Pittsburgh, PA, USA

%% must be scalar.
assert(isscalar(starting_code));
assert(isscalar(ending_code));

%% indices of start and end codes in the whole code sequence.
starting_find = find(nev_codes == starting_code);
ending_find = find(nev_codes == ending_code);

%% array holding the start and end index of all trials.
NEV_trials = {};
i=1;
while ~isempty(ending_find) && ~isempty(starting_find)
    % loop until we don't have starting and end indices left.
    NEV_trials{i}.start = starting_find(1);
    % prune ending_find, finding the smallest index after start.
    ending_find = ending_find(ending_find > starting_find(1));
    if ~isempty(ending_find) % can find an end index.
        NEV_trials{i}.end = ending_find(1);
        % prune starting_find.
        starting_find = starting_find(starting_find > ending_find(1));
        i=i+1;
    else
        NEV_trials(i) = []; % remove this trial cell.
    end
end

end








% Created with NEWFCN.m by Frank González-Morphy
% Contact...: frank.gonzalez-morphy@mathworks.de
% ===== EOF ====== [split_trial_NEV.m] ======
