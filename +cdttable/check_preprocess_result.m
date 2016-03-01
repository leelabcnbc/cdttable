function [ a ] = check_preprocess_result( preprocess_result )
%CHECK_PREPROCESS_RESULT Check preprocess result 
%   


% fields exist.
assert(all(isfield(preprocess_result,{
    'event_codes','event_times','spike_times','spike_locations'})));

event_codes = preprocess_result.event_codes;
event_times = preprocess_result.event_times;
spike_times = preprocess_result.spike_times;
spike_locations = preprocess_result.spike_locations;

% check event codes and times.
assert(iscell(event_codes) && iscell(event_times));
assert(numel(event_codes)==numel(event_times));
assert(numel(event_codes)>=1, 'at least one trial!');

cellfun(@(x,y) assert(numel(size(x))==2  && size(x,2)==1 && ...
    numel(size(y)==2) && size(y,2)==1 &&  numel(x) == numel(y) &&  issorted(y)),...
    event_codes, event_times);


% check spike times and locations.
assert(isnumeric(spike_times) && isnumeric(spike_locations));
assert(numel(size(spike_times))==2 && size(spike_times,2)==1);
assert(numel(size(spike_locations))==2 && size(spike_locations,2)==2);
assert(size(spike_locations,1)==size(spike_times,1));

a = true;

end

