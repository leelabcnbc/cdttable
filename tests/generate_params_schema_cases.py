""" creates several test cases for the schema of import params.
"""
from __future__ import print_function, unicode_literals, division, absolute_import
import json
import copy
import random
import string
import os.path

baseline_import_params = {
    "comment": "",
    "subtrials": [],
    "trial_to_condition_func": "",
}


def random_nonnegative():
    # make sure we can hit 0 with high prob.
    return random.choice([random.uniform(0, 2), 0])


def generate_subtrial_endcode():
    return {
        "start_code": random.randint(-100, 100),
        "end_code": random.randint(-100, 100)
    }


def generate_subtrial_endtime():
    return {
        "start_code": random.randint(-100, 100),
        "end_time": random_nonnegative()
    }


def random_string():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(random.randint(1, 20)))


def generate_valid_import_params():
    import_params = copy.deepcopy(baseline_import_params)
    number_of_subtrials = random.randint(1, 10)
    for _ in range(number_of_subtrials):
        trial_to_insert = random.choice([generate_subtrial_endcode(), generate_subtrial_endtime()])
        if all([trial_to_insert != x for x in import_params['subtrials']]):
            import_params['subtrials'].append(trial_to_insert)
    generate_trial_marker = random.choice([True, False])
    if generate_trial_marker:
        trial_end_code = random.choice([True, False])
        if trial_end_code:
            import_params['trial_start_code'] = random.randint(-100, 100)
            import_params['trial_end_code'] = random.randint(-100, 100)
        else:
            import_params['trial_start_code'] = random.randint(-100, 100)
            import_params['trial_end_time'] = random_nonnegative()

    # then, generate some random margin
    import_params['margin_before'] = random_nonnegative()
    import_params['margin_after'] = random_nonnegative()

    # then, play with comment and trial_to_condition_func
    import_params['comment'] = random_string()
    import_params['trial_to_condition_func'] = random_string()

    remove_comment = random.choice([True, False])
    if remove_comment:
        import_params.pop('comment')

    return import_params


def generate_invalid_import_params():
    """ generate some invalid import params given a valid one.

    :return:
    """
    import_params = generate_valid_import_params()
    how_to_mess_up = random.choice([
        'NO_SUBTRIAL',
        'INCORRECT_TRIAL',
        'NEGATIVE_SUBTRIAL',
        'FLOAT_SUBTRIAL',
        'NEGATIVE_MARGIN',
        'INCOMPLETE_FIELD'
    ])
    if how_to_mess_up == 'NO_SUBTRIAL':
        import_params['subtrials'] = []
    elif how_to_mess_up == 'INCORRECT_TRIAL':
        import_params.pop('trial_start_code', None)
        import_params.pop('trial_end_code', None)
        import_params.pop('trial_end_time', None)

        # add one or add three
        add_one = random.choice([True, False])
        if add_one:
            # I will only add one
            field_to_add = random.choice(['trial_start_code', 'trial_end_code', 'trial_end_time'])
            if field_to_add == 'trial_start_code':
                import_params[field_to_add] = random.randint(-100, 100)
            elif field_to_add == 'trial_end_code':
                import_params[field_to_add] = random.randint(-100, 100)
            elif field_to_add=='trial_end_time':
                import_params[field_to_add] = random_nonnegative()
            else:
                raise ValueError
        else:
            import_params['trial_start_code'] = random.randint(-100, 100)
            import_params['trial_end_code'] = random.randint(-100, 100)
            import_params['trial_end_time'] = random_nonnegative()
    elif how_to_mess_up == 'NEGATIVE_SUBTRIAL':
        trial_to_insert = {
                "start_code": random.uniform(-100, 100),
                "end_time": -random_nonnegative()-0.001
            }
        assert all([trial_to_insert != x for x in import_params['subtrials']])
        import_params['subtrials'].append(trial_to_insert)
    elif how_to_mess_up == 'FLOAT_SUBTRIAL':
        trial_to_insert = {
                "start_code": random.uniform(-100, 100),
                "end_code": random.randint(-100, 100)
            }
        assert all([trial_to_insert != x for x in import_params['subtrials']])
        import_params['subtrials'].append(trial_to_insert)
    elif how_to_mess_up == 'NEGATIVE_MARGIN':
        key_to_mess = random.choice(['margin_before', 'margin_after'])
        import_params[key_to_mess] = -random_nonnegative()-0.001
    elif how_to_mess_up == 'INCOMPLETE_FIELD':
        field_to_drop = random.choice(['subtrials', 'margin_before', 'margin_after', 'trial_to_condition_func'])
        import_params.pop(field_to_drop)
    else:
        raise ValueError

    return import_params


def main(n=10000):
    for i in range(n):
        filename_good = os.path.join("good_import_params","{:05d}.json".format(i+1))
        filename_bad = os.path.join("bad_import_params","{:05d}.json".format(i+1))
        with open(filename_good, 'wt') as f:
            json.dump(generate_valid_import_params(), f, indent=2, separators=(',', ':'))
        with open(filename_bad, 'wt') as f:
            json.dump(generate_invalid_import_params(), f, indent=2, separators=(',', ':'))
        print(i)

if __name__ == '__main__':
    main()
