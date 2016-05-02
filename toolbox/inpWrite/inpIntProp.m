function [ ] = inpIntProp( fid, int)
%INPINTPROP Write interaction properties to Abaqus .inp file
%   Currently supports penalty friction with pressure overclosure:
%   Exponential or Hard
%   
%   Inputs:
%       fid - file id (as set by fopen)
%       int - structure, with fields:
%           int.prop{}.name - property name
%           int.prop{}.po - pressure-overclosure {'EXPONENTIAL', 'HARD'}
%           int.prop{}.frict - friction coefficient
%           if exponential:
%           int.prop{}.e1 - separation where pressure=0
%           int.prop{}.e2 - pressure when separation=0

fprintf(fid,'**\n** INTERACTION PROPERTIES\n**\n');
for ip = 1:numel(int.prop)
    % Write name
    fprintf(fid,'*Surface Interaction, name=%s\n',int.prop{ip}.name);
    % Write friction
    fprintf(fid,'*Friction\n');
    fprintf(fid,'%d,\n',int.prop{ip}.frict);
    % Write pressure-overclosure
    if strcmp(int.prop{ip}.po,'EXPONENTIAL')
        fprintf(fid,'*Surface Behavior, pressure-overclosure=EXPONENTIAL\n');
        fprintf(fid,'%d, %d.\n',int.prop{ip}.e1,int.prop{ip}.e2);
    elseif strcmp(int.prop{ip}.po,'HARD')
        fprintf(fid,'*Surface Behavior, pressure-overclosure=HARD\n');
    end
end


end