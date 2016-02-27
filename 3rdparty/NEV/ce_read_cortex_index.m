function [index]=ce_read_cortex_index(file_name)
%
%  Read all cortex indexes from a cortex data file.
% Inputs
%   file_name      name of Cortex data file
% Outputs
%   index
%       index(n).start_of_header   offset from start of file
%       index(n).length
%       index(n).condition
%       index(n).repeat
%       index(n).block
%       index(n).trial
%       index(n).isi_size
%       index(n).code_size
%       index(n).eog_size
%       index(n).epp_size
%       index(n).resolution
%       index(n).storage_rate
%       index(n).expected
%       index(n).response
%       index(n).response_error
% Globals modified
%    cortex_header_size
%

cortex_header_size=26;  % number of bytes in a Cortex header

if isempty(file_name)
      fprintf('----- Error  No file name given.\n');
   index=[];
   return;
end;
ci_fid=fopen(file_name);
if ci_fid < 1
      fprintf('----- Warning. Cortex file  %s  not found.\n',file_name);
   index=[];
   return;
end;

i=1;
offset=ftell(ci_fid);
while 1 
   if fseek(ci_fid,offset,'bof');  % find start of next index entry
      break;
   end;
   index_entry.start_of_header=ftell(ci_fid);  % mark the location of this entry
   [index_entry.length,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   if n==0  % eof
      if (i==1) 
            fprintf('----- Warning  Cortex file ended with no headers.\n');
         if ci_fid > 0
            fclose(ci_fid);
            ci_fid=-1;
         end;
         index=[];
         return;
      end;
      break;
   end;
   [index_entry.condition,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   index_entry.condition=index_entry.condition+1;  % stored as condx-1
   [index_entry.repeat,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.block,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   index_entry.block=index_entry.block+1;  % stored as block-1
   [index_entry.trial,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.isi_size,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.code_size,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.eog_size,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.epp_size,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.storage_rate,n]=fread(ci_fid,1,'uint8'); % 1 byte
   [index_entry.resolution,n]=fread(ci_fid,1,'uint8'); % 1 byte
   [index_entry.expected,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.response,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   [index_entry.response_error,n]=fread(ci_fid,1,'uint16'); % 2 bytes
   if n==0  % eof
         fprintf('----- Warning [makdat ce_read_cortex_index]. Unexpected end of Cortex file.\n');
      break;
   end;
   % calculate offset of next index entry
   offset=offset + cortex_header_size + index_entry.isi_size + index_entry.code_size ...
        + index_entry.eog_size + index_entry.epp_size;  
   index(i)=index_entry;
   i=i+1;
end;
if ci_fid > 0
   fclose(ci_fid);
   ci_fid=-1;
end;

