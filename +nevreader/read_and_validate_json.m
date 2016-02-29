function [ json_java, isValid ] = read_and_validate_json( json_path, json_schema_path )
%READ_AND_VALIDATE_JSON Summary of this function goes here
%   Detailed explanation goes here
import com.fasterxml.jackson.databind.ObjectMapper
import java.io.File
mapper = ObjectMapper();
json_java = [];
importParamsInstance = mapper.readTree(File(json_path));
schema_java = get_schema(json_schema_path);
isValid = schema_java.validInstance(importParamsInstance);

if isValid
    json_java = mapper.readValue(File(json_path),java.lang.Object().getClass);
end

end

function schema_java = get_schema(schemaFilePath)
import com.fasterxml.jackson.databind.ObjectMapper
import nevreader.root_dir
import java.io.File
import com.github.fge.jsonschema.main.JsonSchemaFactory
mapper = ObjectMapper();
schemaPath = fullfile(root_dir(), schemaFilePath);
schemaInstance = mapper.readTree(File(schemaPath));
factory = JsonSchemaFactory.byDefault();
schema_java = factory.getJsonSchema(schemaInstance);
end
