************
Introduction
************



What's ``cdttable``
===================

``cdttable`` is a MATLAB program designed to convert **trial-based spiking neural data** into a universal format (CDT table) for later analysis.


Use cases of ``cdttable``
=========================

``cdttable`` is for processing **trial-based spiking neural data**, and a typical experiment producing such data is described below in :ref:`typical-experiment`. If this isn't the case for your lab, probably ``cdttable`` won't work for you.

.. _typical-experiment:

a typical experiment generating **trial-based spiking neural data**
-------------------------------------------------------------------

For many labs doing primate (as well as mouse and other animals) experiments, each experiment is a big loop made up of trials, and each trial basically follows the same pattern, such as

#. let the monkey fixiate on red dot on the screen.
#. present some go-cue to make the monkey act.
#. collect the monkey's performance and determine whether this trial has suceeded or not.
#. reward / punish the monkey accordingly.

Usually, there's a set of event codes (or markers) associated with each trial, and different codes refer to different events in the trial. For example, for a `CORTEX <http://www.nimh.nih.gov/labs-at-nimh/research-areas/clinics-and-labs/ln/shn/software-projects.shtml>`_ system, we usually have the following mapping between codes and events.

* ``9``: trial start
* ``18``: trial end
* ``8``: fixation ON
* ``23``: red dot ON
* ``24``: red dot OFF
* ``25``: stimulus 1 ON
* ``26``: stimulus 1 OFF

etc.

After collecting the data, the next step is usually to split the spiking data into trials, and align them according to some event markers, such as stimulus ON, etc. This enables further analysis such as plotting PSTH, etc.


why ``cdttable`` is needed.
-----------------------------
This alignment of data according to marker codes looks simple conceptually but it's difficult to do it in a flexible way. Consider the following scenarios:

* The alignment program ``A`` for experiment A may have three stimuli, yet experiment B only has one. Thus some hack to the program ``A`` is needed for it to work on experiment B.
* The alignment codes for different experiments may be different. For example, some may use fixation ON to align and some may use stimulus ON. This depends on purpose of analysis and the experiment. Again, some hack is needed if one doesn't want to write the second program from scratch.

While writing such alignment code is arguably simple, having separate programs for different experiments is not good practice for the following reasons.

#. there is much overlap between programs, and thus there is a waste of lines and redundancy.
#. since such programs are easy to write, people tend to write them in a hacked fashion, and it's non-portable for other people to use for reproduction purpose.
#. since such programs are similar, it is probably OK to copy-and-paste and then hack the program. But this makes the program prone to bugs. For example, there can be some **dirty tricks** in the original code, perhaps for some specific purposes of the experiment. It's pretty easy for the new program to "inherit" these tricks as well, and nobody would notice it until much further in the analysis...


Motivation
===================

``cdttable`` was initially designed with the following purpose. Simply put, I want data import to be reproducible and flexible.

    The existing analysis tools in our lab (used by Jason and Corentin) are not flexible or well-structured. The biggest problem is that, messy **code change** is necessary for each different experiment. To import data for an new experiment, a considerable amount of code has to be modified. When importing data of old experiments, the code has to be modified again, all over different files. This makes our data import extremely difficult to reproduce and debug. Therefore, based on existing code, I want to make a better package for importing neural data. I hope that this code can evolve well into the future.

Therefore, I wrote a package to solve the data import problem (now at `here <https://github.com/leelabcnbc/yimeng_neural_analysis_toolbox/>`_). However, it seems that the problem mentioned above exists in many labs as well. Therefore, I refactored the old package so that it can be general enough to accomodate the different setups of different labs.





Random things
===================



Why called CDT table
--------------------

CDT is the data structure used in Jason and Corentin's legacy code. I don't know what CDT (cortex data tree?) stands for. However, since the structure used in this toolbox is inspired by what Corentin called CDT, I just borrow this name. In my opinion, CDT structure is not flexible, with its high dimensional cell arrays. So inspired by CDT, I use a more tabular structure to save the imported data, and call this "CDT table".




An example of CDT table vs. CDT
-------------------------------


Consider a NEV file with 32 channels (all unit 1's of 32 electrodes), 40 conditions, and 10 trials per condition. For a CDT table structure, there will be 40x10=400 rows, each row having all info about that trial. For a CDT structure, There's a 32 x 40 x 10 (numChannel x numCondition x numTrial) ``EVENTS`` cell array, where each cell saves a row vector of the spike time of that channel on that trial of that condition. Similarly, for ``starttime`` (``stoptime``) in CDT table, there's a 40 x 10 ``data.starttime`` cell array. The disadvantages of CDT are


1. it's difficult to remember the meanings of all dimensions in that 3D ``EVENTS`` array or that 2D ``data.starttime`` array
2. sometimes, we don't have same number of trials for each condition, so some elements in 3D or 2D arrays of CDT structure are not meaningful.

Essentially, the nature of neural data is **trial based**, rather than **a high dimensional array**. In CDT table structure, since all fields are named, we don't have to remember the meanings of dimensions, and we don't have to fill in empty cells for unequal number of conditions, creating some confusion. Moreover, it's straightforward to convert CDT table to CDT, yet not the other way around. In addition, CDT format can only import 1 unit for each electrode during each import, and this is not natural for multi unit electrodes.
