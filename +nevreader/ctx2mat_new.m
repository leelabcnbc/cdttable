function [ ctx_data ] = ctx2mat_new( file_name )
%CTX2MAT_NEW convert cortex file to a matlab cell array.
%   Based on Cortex Explorer 0.75
%   http://dally.nimh.nih.gov/matoff/cortex_explorer.html
%   everything is preserved for each trial.
%   Yimeng Zhang, 09/17/2013
%   Pittsburgh, PA

import nevreader.ce_read_cortex_index
import nevreader.ce_read_cortex_record

ctx_index = ce_read_cortex_index(file_name);

fid = fopen(file_name); 

ctx_data = cell(length(ctx_index),1);

for i = 1:length(ctx_index)
    temp_record = ce_read_cortex_record(fid,ctx_index(i),0); % 0 means don't exclude analog signals.
    ctx_data{i}.header = ctx_index(i);
    ctx_data{i}.record = temp_record;
end

fclose(fid);

end