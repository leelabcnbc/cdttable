from __future__ import print_function, unicode_literals, division, absolute_import
import sys
import os
import json
import jsl


class SubTrialEndTime(jsl.Document):
    start_code = jsl.IntField(required=True)
    end_time = jsl.NumberField(minimum=0, required=True)


class SubTrialEndCode(jsl.Document):
    start_code = jsl.IntField(required=True)
    end_code = jsl.IntField(required=True)


SubTrial = jsl.OneOfField([jsl.DocumentField(SubTrialEndTime),
                           jsl.DocumentField(SubTrialEndCode)])


class CDTTableImportParamsSchemaCommon(jsl.Document):
    comment = jsl.StringField()
    subtrials = jsl.ArrayField(items=SubTrial, unique_items=True, required=True, min_items=1)
    margin_before = jsl.NumberField(minimum=0, required=True)  # 0.3 by default in previous implementation.
    margin_after = jsl.NumberField(minimum=0, required=True)  # 0.3 by default in previous implementation.
    trial_to_condition_func = jsl.StringField(required=True)  # should be a function of both event codes and trial idx.


class CDTTableImportParamsSchemaEndTime(CDTTableImportParamsSchemaCommon):
    trial_start_code = jsl.IntField()
    trial_end_time = jsl.NumberField(minimum=0)


class CDTTableImportParamsSchemaEndCode(CDTTableImportParamsSchemaCommon):
    trial_start_code = jsl.IntField()
    trial_end_code = jsl.IntField()


CDTTableImportParamsSchema = jsl.OneOfField([jsl.DocumentField(CDTTableImportParamsSchemaEndTime),
                                             jsl.DocumentField(CDTTableImportParamsSchemaEndCode)])


class User(jsl.Document):
    id = jsl.StringField(required=True)
    login = jsl.StringField(required=True, min_length=3, max_length=20)


if __name__ == '__main__':
    # output the schema.
    with open(os.path.join(sys.path[0], 'import_params_schema.json'), 'wt') as f:
        f.write((json.dumps(CDTTableImportParamsSchema.get_schema(ordered=True), indent=4)))
