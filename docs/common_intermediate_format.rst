********************************
Common Intermediate Format (CIF)
********************************

| Yimeng Zhang
| Feb. 29, 2016

.. todo:: enforce all the constraints in the actual code, and test that shuffling indeed works.

To use ``cdttable``, the user must present their spiking neural data in a particular format called
Common Intermediate Format (CIF). The spiking neural data for N trials
must be a MATLAB ``struct`` with the following fields.

``event_codes``
    a N x 1 cell array, i-th element being a column vector storing the event codes for i-th trial. The order of
    event codes must reflect the actual temporal order they appear, which is natural for real data. The N elements
    can be shuffled without affecting the correctness of the program.

``event_times``
    a N x 1 cell array, i-th element being a column vector of same length as i-th element in ``event_codes``,
    storing the timestamps of event codes. The timestamps with in any trial must be non-decreasing, which is natural
    for real data. Similarly, the elements can be shuffled, but should match that of ``event_codes``.

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
