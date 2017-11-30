# cdttable

[![Documentation Status](http://readthedocs.org/projects/cdttable/badge/?version=latest)](http://cdttable.readthedocs.org/en/latest/?badge=latest)

A MATLAB program designed to convert trial-based spiking neural data into a universal format (CDT table) for later analysis.

for documentation, click the badge above.


# how to create a '.json' file needed for this package  

First, you need to know what a '.tm' (timing) file is. This is the file that controls the experiment. It tells the computer what to do within a trial. For example, when the computer should display the red dot and display it where. Or query for whether the monky has fixed on the red dot yet or not. If has fixation, what to do next. If hasn't fixed yet, retry? And so on.  

In this sequence of controlments, it also keeps a record of what has happened and this record is stored in '.NEV' file. 

Before we talk about the record it created, I should tell you there is a encoding table. Some example entries in the table looks like this:  
FIXATION_ OCCURS        <----  8  
END_INTER _ TRIAL      <---- 10  
START_ WAIT _ FIXATION  <---- 11  
END _ WAIT _ FIXATION   <---- 12  
START _ WAIT _ LEVER    <---- 13  
END _ WAIT _ LEVER      <---- 14  
START _ PRE _ TRIAL     <---- 15  
END_POST _ TRIAL      <---- 18  
TURN_TEST0 _ ON       <---- 23  
TURN_TEST0 _ OFF      <---- 24  
TURN_TEST1 _ ON       <---- 25  
TURN_TEST1 _ OFF      <---- 26  
TURN_FIXSPOT _ ON     <---- 35  
TURN_FIXSPOT _ OFF    <---- 36  
REWARD_GIVEN               <---- 96  

So within each trail, when it detects FIXATION_ OCCURS, it writes down a 8 and this very time point (relative to the begining of recording) in its record. When REWARD_GIVEN, it writes down 96. The syntax for writes down a code is 'Record(event_ name)', where the event_ name is something like FIXATION_ OCCURS.

The most core action of cdttable package is to slice out the trials and through away the 'useless' inter-trail recordings from NEV, then align the slices and save into a '.mat' file. How does this package do the slicing? It takes a template of what a trial looks like, and then according to the template, it do the extraction. 

'.json' is the template

In '.json' file, you will find a sequence of field and value pairs. The order of the pairs matters! The slicing depends on that. It looks for the 1st code in the record kept by '.tm' file. If the code is find, it will then continue to search for the 2nd code, given by your '.json' file, in later time stamps in the record. And so on... If it failed to find a code, it will start from your 1st code again. If it finshed find one complete set of codes given by your '.json', it will crop out all the spikes (and the time point when this spike was fired) happend within this time period and save them as one trial.

So you need to figure out what a successful trial looks like. To be successful, it must have certain sequence of events happend in a sepecific order. This information can be found from you '.tm' file. You just need to think yourself as the computer and travel from the first sentence to the last sentence of instructions in '.tm' file. When you do that, you are going to figure out what the '.tm' file has written down for a successful trial. And what you can expect to use as your template to guide your slicing.
