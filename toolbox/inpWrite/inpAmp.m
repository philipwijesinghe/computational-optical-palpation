function [ ] = inpAmp( fid, amp)
%INPAMP Write amplitudes to Abaqus .inp file
%   Currently supports tabular only
%
%   Inputs:
%       fid - handle to .inp file (use fopen)
%       amp - structure:
%           amp.name - amplitude name
%           amp.table - 1D array of amplitudes [time,amp,time,amp...]
%
%   Example:
%       amp.name = 'amp-1';
%       amp.table = [0,0; 1,1]; % smoothed step from 0 to 1 * boundary disp
%       amp.table = reshape(amp.table',1,[]);
%


fprintf(fid,'*Amplitude, name=%s, definition=SMOOTH STEP\n', amp.name);
for ai = 1:length(amp.table)-1
    fprintf(fid,'%11g, ', amp.table(ai));
end
fprintf(fid,'%11g\n', amp.table(end));


end