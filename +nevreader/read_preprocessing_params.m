function [ import_params_java, isValid ] = read_preprocessing_params( import_params_path, trial_template_path )
%READ_PREPROCESSING_PARAMS read preprocessing parameters for NEV/CTX files
%   
%    :param import_params_path: path to JSON file of import params
%    :return: ``[ import_params_java, isValid ]``. second argument logical,
%             whether import_params valid or not,
%             first one being the java object of params if ``isValid``,
%             and empty (``[]``) otherwise.
%   
import nevreader.read_and_validate_json

[import_params_java, isValidImportParams] = ...
    read_and_validate_json( import_params_path, 'nev_preprocessing_params_schema.json' );
[template_java, isValidTemplate] = ...
    read_and_validate_json( trial_template_path, 'nev_rewarded_trial_template_schema.json' );

isValid = isValidTemplate && isValidImportParams;

if isValid
    import_params_java.put('trial_template', template_java);
else
    import_params_java = [];
end
end
