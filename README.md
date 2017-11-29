# cdttable

[![Documentation Status](http://readthedocs.org/projects/cdttable/badge/?version=latest)](http://cdttable.readthedocs.org/en/latest/?badge=latest)

A MATLAB program designed to convert trial-based spiking neural data into a universal format (CDT table) for later analysis.

for documentation, click the badge above.


# how to create a '.json' file needed for this package  

First, you need to know what's a '.tm' (timing) file. This is the file that controls the experiment. It tells the computer what to do within a trial. For example, when should the computer display the red dot and displayed it where. And query for whether the monky has fixed on the red dot yet or not. If has fixation, what to do next. If hasn't fixed yet, retry? And so on.  

In this sequence of controlments, it also keep a record of what has happened and transfered that record into '.NEV' file. 

Before we talk about the record it created, I should tell you there is a encoding table, which looks like this:
