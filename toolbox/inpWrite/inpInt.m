function [ ] = inpInt( fid, int)
%INPINT _SUPERSEDED

fprintf(fid,'**\n** INTERACTION PROPERTIES\n**\n');
for ip = 1:numel(int.prop)
    fprintf(fid,'*Surface Interaction, name=%s\n',int.prop{ip}.name);
    fprintf(fid,'1.,\n');
    fprintf(fid,'*Friction, slip tolerance=0.005\n');
    fprintf(fid,'%d,\n',int.prop{ip}.frict);
    if strcmp(int.prop{ip}.po,'EXPONENTIAL')
        fprintf(fid,'*Surface Behavior, pressure-overclosure=EXPONENTIAL\n');
        fprintf(fid,'%d, %d.\n',int.prop{ip}.e1,int.prop{ip}.e2);
    elseif strcmp(int.prop{ip}.po,'HARD')
        fprintf(fid,'*Surface Behavior, pressure-overclosure=HARD\n');
    end
end



fprintf(fid,'**\n** INTERACTIONS\n**\n');
for ii = 1:numel(int.pair)
    fprintf(fid,'** Interaction: %s\n',int.pair{ii}.name);
    fprintf(fid,'*Contact Pair, interaction=%s, type=SURFACE TO SURFACE\n',int.pair{ii}.prop);
    fprintf(fid,'%s, %s\n',int.pair{ii}.s,int.pair{ii}.m);
end


end