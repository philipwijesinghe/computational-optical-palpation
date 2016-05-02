function [ ] = inpInts( fid, int, step)
%INPINTS Write interactions to Abaqus .inp file
%   Currently supports contact pair formulation
%
%   Inputs:
%       fid - file id (as set by fopen)
%       int - structure, with fields:
%           int.pair{}.name - property name
%           int.prop{}.prop - interaction property name (previously defined
%                                   in inpIntProp)
%           int.prop{}.m - master surface name (previously defined in inpPart)
%           int.prop{}.s - slave surface name (previously defined in inpPart)
%       step - 'standard' or 'explicit' step type


fprintf(fid,'**\n** INTERACTIONS\n**\n');
switch step
    case 'standard'
        for ii = 1:numel(int.pair)
            fprintf(fid,'** Interaction: %s\n',int.pair{ii}.name);
            fprintf(fid,'*Contact Pair, interaction=%s, type=SURFACE TO SURFACE\n',int.pair{ii}.prop);
            fprintf(fid,'%s, %s\n',int.pair{ii}.s,int.pair{ii}.m);
        end
    
    case 'explicit'
        for ii = 1:numel(int.pair)
            fprintf(fid,'** Interaction: %s\n',int.pair{ii}.name);
            fprintf(fid,'*Contact Pair, weight=0.5, interaction=%s, mechanical constraint=KINEMATIC, cpset=%s\n',...
                int.pair{ii}.prop, int.pair{ii}.name);
            fprintf(fid,'%s, %s\n',int.pair{ii}.s,int.pair{ii}.m);
        end
        
end

end