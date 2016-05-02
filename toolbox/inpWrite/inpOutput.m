function [ ] = inpOutput( fid, step )
%INPOUTPUT Write output requests to Abaqus .inp file
%
%   Inputs:
%       fid - file id (as set by fopen)
%       step - 'standard' or 'explicit' step type

switch step
    case 'standard'
        fprintf(fid,'**\n** OUTPUT REQUESTS\n**\n');
        fprintf(fid,'*Restart, write, frequency=0\n');
        fprintf(fid,'**\n** FIELD OUTPUT: F-Output-1\n**\n');
        fprintf(fid,'*Output, field\n');
        fprintf(fid,'*Node Output\nCF, COORD, RF, U\n');
        fprintf(fid,'*Element Output, directions=YES\nLE, PE, PEEQ, PEMAG, S\n');
        fprintf(fid,'*Contact Output\nCDISP, CSTRESS\n');
        fprintf(fid,'**\n** HISTORY OUTPUT: H-Output-1\n**\n');
        fprintf(fid,'*Output, history, variable=PRESELECT\n');
    case 'explicit'
        fprintf(fid,'**\n** OUTPUT REQUESTS\n**\n');
        fprintf(fid,'*Restart, write, number interval=1, time marks=NO\n');
        fprintf(fid,'**\n** FIELD OUTPUT: F-Output-1\n**\n');
        fprintf(fid,'*Output, field, number interval=20\n');
        fprintf(fid,'*Node Output\nA, COORD, RF, U, V\n');
        fprintf(fid,'*Element Output, directions=YES\nLE, S\n');
        fprintf(fid,'*Contact Output\nCSTRESS,\n');
        fprintf(fid,'**\n** HISTORY OUTPUT: H-Output-1\n**\n');
        fprintf(fid,'*Output, history, variable=PRESELECT\n');
end

end