from __future__ import print_function, unicode_literals, division, absolute_import
import sys
import os
import json
import jsl


class SingleCodeSingleMissable(jsl.Document):
    type = jsl.StringField(enum=["SINGLE"], required=True)
    code = jsl.IntField(required=True)
    missable = jsl.BooleanField(enum=[False], required=True)  # currently, missable code is not supported.


class SingleCodeSingleNotMissable(jsl.Document):
    type = jsl.StringField(enum=["SINGLE"], required=True)
    code = jsl.IntField(required=True)


SingleCodeSingle = jsl.OneOfField([jsl.DocumentField(SingleCodeSingleMissable),
                                   jsl.DocumentField(SingleCodeSingleNotMissable)])


class SingleCodeRange(jsl.Document):
    type = jsl.StringField(enum=["RANGE"], required=True)
    min_value = jsl.IntField(required=True)
    max_value = jsl.IntField(required=True)
    missable = jsl.BooleanField(required=True)


SingleCodeField = jsl.OneOfField([SingleCodeSingle,
                                  jsl.DocumentField(SingleCodeRange)])


class RewardedTrialTemplate(jsl.Document):
    codes = jsl.ArrayField(items=SingleCodeField, required=True, min_items=1)
    comment = jsl.StringField()
    startcode = jsl.IntField(required=True)
    stopcode = jsl.IntField(required=True)
    rewardcode = jsl.IntField(required=True)


class NEVPreprocessingParams(jsl.Document):
    comment = jsl.StringField()
    spike_no_secondary_unit = jsl.BooleanField(required=True)
    spike_no_255_unit = jsl.BooleanField(required=True)
    spike_no_0_unit = jsl.BooleanField(required=True)
    throw_high_byte = jsl.BooleanField(
        required=True)  # I dropped "fix_nev" because this works whether you fix it or not.
    fix_nev = jsl.BooleanField(required=True)


if __name__ == '__main__':
    # output the schema.
    with open(os.path.join(sys.path[0], 'nev_preprocessing_params_schema.json'), 'wt') as f:
        f.write((json.dumps(NEVPreprocessingParams.get_schema(ordered=True), indent=2, separators=(',', ':'))))
    with open(os.path.join(sys.path[0], 'nev_rewarded_trial_template_schema.json'), 'wt') as f:
        f.write((json.dumps(RewardedTrialTemplate.get_schema(ordered=True), indent=2, separators=(',', ':'))))
