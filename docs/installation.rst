************
Installation
************

| Yimeng Zhang
| Feb. 29, 2016

System Requirements
===================

For users
--------------------
* MATLAB R2012b or higher should work, although I personally only tested the program on R2012b, R2014a, and R2015a.

For developers
--------------------
If you also want to run all tests and generate the doc, apart from MATLAB, a Python 2.7.x environment plus the following packages (the ones in ``/requirements.txt`` of the repository) should do.

.. literalinclude:: ../requirements.txt


How to install
===================

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
    * This is needed because the program depends on some Java packages yet some of them are already shipped with the MATLAB, but in older versions, which will shadow the packages provided by ``cdttable``. This ``hack_javapath.m`` will make the packages from my program take precedence. The old packages from MATLAB are too old so that they will usually break ``cdttable``. Of three versions I tested, only R2015a works without this hack. Notice that this hack would affect MATLAB **globally**, and you may want to revoke it when not using the package.
#. Every time before using the program, do the following.
    * open MATLAB and change directory to root directory of ``cdttable``.
    * run ``initialize_path`` in MATLAB to add path. Or you can do this manually.

Run the demo program
=====================

change directory to ``/demos`` and run ``import_NEV_demo``. You should see a file ``import_NEV_demo_result.mat`` generated under ``/demos/import_NEV_demo_results``.

