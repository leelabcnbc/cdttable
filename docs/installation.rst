************
Installation
************

| Yimeng Zhang
| Feb. 29, 2016

System Requirements
===================

For users
---------
* MATLAB R2012b or higher should work, although I personally only tested the program on R2012b, R2014a, and R2015b.

For developers
--------------
If you also want to run all tests and generate the doc, apart from MATLAB, a Python 2.7.x environment plus the following packages (the ones in ``/requirements.txt`` of the repository) should do.

.. literalinclude:: ../requirements.txt


How to install
==============

.. todo:: put some release tags on the GitHub.
.. todo:: verify the program on Windows.
.. todo:: add credits to the 3rd party files.
.. todo:: more doc on how to revoke the classpath hack.


#. obtain the latest version of ``cdttable`` from https://github.com/leelabcnbc/cdttable by ``git clone`` the repository or clicking "Download ZIP" on the page.
#. (For Mac / Linux) Open a terminal window and install 3rd party dependencies. This has two steps.
    #. Change directory to ``/3rdparty``, and run ``./install_3rdparty.sh``. This is required.
    #. Change directory to ``/3rdparty/NEV``, and run ``./install_3rdparty.sh``. This is not necessary if you don't want to run the demo code or use the provided :mat:mod:`+nevreader` to preprocess NEV files.
#. (For Windows) do the above step manually.
    #. copy ``/3rdparty/json-schema-validator-2.2.6-lib.jar`` to ``/+cdttable``.
    #. In ``/3rdparty/NEV``, copy ``json-schema-validator-2.2.6-lib.jar``, ``ce_read_cortex_index.m``, and ``ce_read_cortex_record.m`` to ``/+nevreader``, and expand ``NPMK-4.0.0.0.zip``. After this extraction, there should be a folder called ``NPMK`` in ``/3rdparty/NEV/``, and there should be many files inside it instead of a single nested folder.
#. (Strongly recommended) open MATLAB, change directory to root directory of the program, run ``hack_javapath.m``, and restart MATLAB (must restart MATLAB for the change to take effect).
    * This is needed because the program depends on some Java packages yet some of them are already shipped with the MATLAB, but in older versions, which will shadow the packages provided by ``cdttable``. This ``hack_javapath.m`` will make the packages from my program take precedence. The old packages from MATLAB are too old so that they will usually break ``cdttable``. Of three versions I tested, only R2015b works without this hack. Notice that this hack would affect MATLAB **globally**, and you may want to revoke it when not using the package.
#. Every time before using the program, do the following.
    * open MATLAB and change directory to root directory of ``cdttable``.
    * run ``initialize_path`` in MATLAB to add path. Or you can do this manually.

Run the demo program
====================

change directory to ``/demos`` and run ``import_NEV_demo``. You should see a file ``import_NEV_demo_result.mat`` generated under ``/demos/import_NEV_demo_results``.

.. todo:: add link to template specification, parameter specification.

.. _what-is-in-the-demo:

What's done by the demo
-----------------------
Basically, this demo program converts two NEV files into two CDT tables, one for each file. These two NEV files are the part of the data for an old experiment in our lab. During each trial, 3 stimuli were presented to the monkey in sequence, and there are 416 trials and 416*3 stimuli in total for each file (so each stimulus only presented once per file).


    .. literalinclude:: ../demos/import_NEV_demo.m
        :language: matlab


#. In the first cell block of the code (``%% load file list.``), the filelists of NEV and CTX files are constructed. CTX files are just to double check the correctness of event codes in the NEV files and can be omitted.
#. In the second block (``%% get path for parameters``), the paths of parameter files for the conversion are specified. There are three parameter file, two (``templatePath``, ``preprocessParamsPath``) for the :mat:mod:`+nevreader` package to convert NEV to a common intermediate format, which is specified in :doc:`common_intermediate_format`, and the third one ``importParamsPath`` specifies how to extract and align event codes. The first two files are specific to :mat:mod:`+nevreader` and will be ignored for now, except that you should know they convert NEV files into the :doc:`common_intermediate_format`. The content of the third file (which is a JSON document) is as follows.

    .. literalinclude:: ../+cdttable/demo_import_params/edge_test.json
        :language: json

    * ``comment`` is just some description of the import parameters, and is ignored by the program.
    * ``subtrials`` is the most important field in the file, whose elements specify the markers of three stimuli in each trial. In this case, stimulus 1 ON/OFF is marked by 25/26, stimulus 2 ON/OFF by 27/28, and stimulus 3 ON/OFF by 29/30.
    * ``trial_to_condition_func`` specifies how to extract the condition number from event codes in the trial and the trial index. In this case, the condition number is encoded by the quotient and and remainder of the condition number divided by 64, and the quotient and remainder are added by 192 in the end to avoid confusion with other event codes.
    * ``margin_before`` and ``margin_after`` specifies the margins in spike extraction window. Given the three subtrials as specified above, for each trial, the program would collect all spikes and events between ``(t(25) - margin_before, t(30) + margin_after)``, where ``t(x)`` refers to the timestamp for event code with value x. For example, if for some particular trial, code 25 appears in 133.5 second (relative to some reference time, say start of recording), and code 30 appears in 134.0 second, then the program would collect all codes and spikes during time window ``(133.2s, 134.3s)`` (notice it's open interval; it's for compatibility with legacy program in our lab). For more info on how to specify the import parameter file, see :doc:`import_params_schema`.

#. In the third block (``%% do the actual conversion.``), the actual conversion is performed, by calling :mat:func:`+cdttable.import_files`, and passing in the preprocessing function for NEV files :mat:func:`+nevreader.preprocessing_func`, the arguments to pass into the preprocessing function ``argList``, and the path of import parameter file ``importParamsPath``.
#. In the fourth block (``%% save the result.``), the resultant CDT tables are saved as ``import_NEV_demo_result.mat``.
