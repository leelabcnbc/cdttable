function [ CDTTables ] = import_files( preprocess_func, arglist, import_params )
%IMPORT_FILES convert preprocessed data into CDT.
%   Detailed explanation goes here
import cdttable.import_one_file

% call import_one_file on each set of arguments.
CDTTables = cellfun(@(x) import_one_file(preprocess_func(x{:}), import_params), arglist, 'UniformOutput', false);

end

