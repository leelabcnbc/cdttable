function [cortex_record]=ce_read_cortex_record(input_fid,cortex_index,exclude_analog)
%
%  Read one record from a Cortex data file.  
%  
%  Inputs
%    input_fid          fid of input file
%    cortex_index       one Cortex index entry (see ce_read_cortex_index()) for structure
%    exclude_analog     =1 skip analog data, return empty analog arrays
%  Outputs
%    cortex_record
%        cortex_record.event_time[]       time stamps for event codes
%        cortex_record.event_code[]       event codes
%        cortex_record.eog[:,2]           primary (X) and secondary (Y) channel data
%        cortex_record.epp[:]             epp channel data 
%        cortex_record.epp_channels[:]    matching channel number for each EPP data point
%  
% This program assumes all files any with EPP data have exactly 2 EPP channels
%
cortex_header_size=26;  % number of bytes in a Cortex header
if isempty(cortex_index)
   fprintf('----- Warning. Completely empty Cortex index entry encountered.\n');
   cortex_record=[];
   return;
end;
if input_fid < 0
   fprintf('----- Error. Cortex data file is not open.\n');
   cortex_record=[];
   return;
end;

data_size= cortex_index.isi_size + cortex_index.code_size + cortex_index.eog_size ...
          + cortex_index.epp_size; 

if data_size==0     % handle empty record
   cortex_record.event_time=[];
   cortex_record.event_code=[];
   cortex_record.eog=[];
   cortex_record.epp=[];
   return;
end;

offset=cortex_index.start_of_header + cortex_header_size;

if fseek(input_fid,offset,'bof');  % find start of data
   cortex_record=[];
   fprintf( ...
      'Error . Could not find start of cortex data at offset: %d in file %s.\n', ...
      offset, fopen(input_fid));
   return;
end;

num_of_codes=cortex_index.code_size / 2;
[cortex_record.event_time,n]=fread(input_fid,num_of_codes,'uint32'); % 4 bytes for each event time
[cortex_record.event_code,n]=fread(input_fid,num_of_codes,'uint16'); % 2 bytes for each event code
% epp array comes next, even though it is later in the header than the eog

   samples=cortex_index.epp_size / 2;
if exclude_analog==1
   fseek(input_fid,(2*samples),'cof');  % skip over EPP data
   cortex_record.epp=[];
else
   epp_samples=fread(input_fid,[samples],'uint16'); % 2 bytes x n samples epp
   epp_channel_list=bitand(epp_samples,15);   % save all the channel number tags
   cortex_record.epp_channels=epp_channel_list';  
   epp_samples=bitshift(epp_samples,-4);  % remove channel number tags from samples
   cortex_record.epp = epp_samples';  % transpose and save
end;

% eog always comes as two channels.  There is no channel information on these.
samples=cortex_index.eog_size / 4;
if exclude_analog==1
   fseek(input_fid,(2*2*samples),'cof');  % skip over EOG data
   cortex_record.eog=[];
else
   [eog_samples,n]=fread(input_fid,[2 samples],'int16');
   cortex_record.eog=eog_samples';  % 2 bytes x 2 channels x n samples eog
end;
