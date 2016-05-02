function [ ] = inpBCnodal( fid, partAssembly, node_id, uz, varargin )
%INPBCnodal - node by node definition of boundary displacement
%   Currently limited to Displacement/Rotation
%
%   Inputs:
%       fid - file id (as set by fopen)
%       partAssembly - name of boudary condition set (symbolic in inp file,
%                                   Abaqus will rename appropriately)
%       node_id - 1D array of node id's
%       uz - (z-)displacement associated with node id's
%       amp - (optional, reqired for 'explicit') amplitude of BC
%


% Define BC's
fprintf(fid,'**\n** BOUNDARY CONDITIONS\n**\n');
fprintf(fid,'** Name: %s Type: Displacement/Rotation\n',[partAssembly 'BC']);
if nargin<5
    fprintf(fid,'*Boundary\n');
else
    amp = varargin{1};
    fprintf(fid,'*Boundary, amplitude=%s\n',amp);
end

% Write individual BC's for each node
for di = 1:length(node_id)
    fprintf(fid,'Assembly.%s.%d, 3, 3, %12g\n',...
        partAssembly,node_id(di),uz(di));
end

end