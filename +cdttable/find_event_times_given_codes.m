function [ alignTimes ] = find_event_times_given_codes( alignCodes,eventCodes,eventTimes )
%FIND_EVENT_TIMES_GIVEN_CODES find (earlist) time of events given coides.
%
%   :param alignCodes: codes to find to time
%   :param eventCodes: array of event codes
%   :param eventTimes: array of event times.
%   :return: times of first occuring alignCodes.

[~,codeIdx] = ismember(alignCodes,eventCodes);
alignTimes = eventTimes(codeIdx);

end

