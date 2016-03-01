********************************
Common Intermediate Format (CIF)
********************************

| Yimeng Zhang
| Feb. 29, 2016

To use ``cdttable``, the user must present their spiking neural data in a particular format called
Common Intermediate Format (CIF). To see some examples of CIF, simply run :mat:func:`tests.generate_one_preprocess_result`, and the first argument returned by the function is a valid CIF.

Formal Specification
====================

The CIF for some spiking neural data for N trials and M spikes
must be a MATLAB ``struct`` with the following fields.

``event_codes``
    a N x 1 cell array, i-th element being a column vector storing the event codes for i-th trial. The order of
    event codes must reflect the actual temporal order they appear, which is natural for real data.
    The order of N elements should follow the actual temporal order trials appear. In any case, the i-th element in the
    cell array will be considered as the i-th trial by the program, and passed in ``i`` when computing condition number.

``event_times``
    a N x 1 cell array, i-th element being a column vector of same length as i-th element in ``event_codes``,
    storing the timestamps of event codes.
    The timestamps with in any trial must be non-decreasing and match the order of corresponding codes, which is natural
    for real data. Similarly, the order of N elements should follow the actual temporal order trials appear.

``spike_times``
    a M x 1 column vector, specifying the timestamps of all spikes in the data. The order of spikes can be shuffled
    without affecting the correctness of the program.

``spike_locations``
    a M x 2 matrix, i-th row corresponding to the i-th spike in ``spike_times``. For each row, first element denotes
    the electrode number of the spike, and second element the unit number. For our lab's settting (NEV files),
    electrode number has a range of 1-96, and unit number has a range of 0-255. The combination of electrode number and
    unit number is the spike's location, which is the neuron that emits the spike in this context.
    Similarly, the rows can be shuffled, but should match that of ``spike_times``.


Notice that all timestamps (for codes and spikes) must be w.r.t. to some common origin, such as start of recording.
Such timestamps are the most natural ones when extracted from the raw recording file, but may not be the case if they
are extracted from the experiment control program, which may use the start of each trial as time origin.

