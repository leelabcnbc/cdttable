function [ CDTTables, import_params_string ] = import_files( preprocess_func, arglist, import_params_path )
%IMPORT_FILES convert preprocessed data into CDT.
%   Detailed explanation goes here
import cdttable.import_one_file
import cdttable.read_import_params
import cdttable.add_rm_dependency
add_rm_dependency('add');
[ import_params_java, isValid, import_params_string ] = read_import_params( import_params_path );
assert(isValid);
% call import_one_file on each set of arguments.
CDTTables = cellfun(@(x) import_one_file(preprocess_func(x{:}), import_params_java), arglist, 'UniformOutput', false);
add_rm_dependency('rm');
end

