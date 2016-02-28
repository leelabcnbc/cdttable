function [ import_params_java, isValid ] = read_import_params( import_params_path )
%READ_IMPORT_PARAMS read import parameters
%   
%    :param import_params_path: path to JSON file of import params
%    :return: ``[ import_params_java, isValid ]``. second argument logical,
%             whether import_params valid or not,
%             first one being the java object of params if ``isValid``,
%             and empty (``[]``) otherwise.
%   
import com.fasterxml.jackson.databind.ObjectMapper
import java.io.File
mapper = ObjectMapper();
import_params_java = [];
importParamsInstance = mapper.readTree(File(import_params_path));
schema_java = get_schema();
isValid = schema_java.validInstance(importParamsInstance);
if isValid
    import_params_java = mapper.readValue(File(import_params_path),java.lang.Object().getClass);
end
end

function schema_java = get_schema()
import com.fasterxml.jackson.databind.ObjectMapper
import cdttable.root_dir
import java.io.File
import com.github.fge.jsonschema.main.JsonSchemaFactory
mapper = ObjectMapper();
schemaPath = fullfile(root_dir(), 'import_params_schema.json');
schemaInstance = mapper.readTree(File(schemaPath));
factory = JsonSchemaFactory.byDefault();
schema_java = factory.getJsonSchema(schemaInstance);
end