function [ ] = inpPart( fid, part_id, node, elem , mesh, material, varargin)
% parse for correct input

% required:
%   mesh.mesh_type
%   mesh.elem_type
%   material.name
%           if 1x1 string - then single material name will be
%                   appied to all elements
%           if nx2 cell array - then {n,1} is element set name
%                                and {n,2} is material name
%               !care - all elements require section assignment
%
% optional
%   sets - cell array, where for n desired sets
%           sets{n,1} - set name: string - alphanumeric
%           sets{n,2} - set type: string in {'node','elem','surf'}
%           sets{n,3} - set list of nodes/elements: mx1 array
%

fprintf(fid,'**\n** PARTS\n**\n*Part, name=%s\n',part_id);
% Write node coordinates to file
fprintf(fid,'*Node\n');
fprintf(fid,'%d, %d, %d, %d\n',node');
% Write element connectivity
if strcmp(mesh.mesh_type,'tet')
    fprintf(fid,'*Element, type=%s\n',mesh.elem_type);
    fprintf(fid,'%d, %d, %d, %d, %d\n',elem');
elseif strcmp(mesh.mesh_type,'hex')
    fprintf(fid,'*Element, type=%s\n',mesh.elem_type);
    fprintf(fid,'%d, %d, %d, %d, %d, %d, %d, %d, %d\n',elem');
elseif strcmp(mesh.mesh_type,'tet10')
    fprintf(fid,'*Element, type=%s\n',mesh.elem_type);
    fprintf(fid,'%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d\n',elem');
end
% Generate node and element sets for the entire body
fprintf(fid,'*Nset, nset=%sBodySet, generate\n',part_id);
fprintf(fid,'%d, %d, %d\n',1,size(node,1),1);
fprintf(fid,'*Elset, elset=%sBodySet, generate\n',part_id);
fprintf(fid,'%d, %d, %d\n',1,size(elem,1),1);
%
if nargin>5
    sets = varargin{1};
    for ii = 1:size(sets,1)
        switch sets{ii,2}
            case 'node'
                fprintf(fid,'*Nset, nset=%s \n',sets{ii,1});
                fprintf(fid,'%d, %d, %d\n',sets{ii,3});
                fprintf(fid,'\n');
            case 'elem'
                fprintf(fid,'*Elset, elset=%s \n',sets{ii,1});
                fprintf(fid,'%d, %d, %d\n',sets{ii,3});
                fprintf(fid,'\n');
            case 'surfS3'
                fprintf(fid,'*Elset, elset=%s_S, internal\n',sets{ii,1});
                fprintf(fid,'%d, %d, %d\n',sets{ii,3});
                fprintf(fid,'\n');
                fprintf(fid,'*Surface, type=ELEMENT, name=%s\n',sets{ii,1});
                fprintf(fid,'%s_S, S3\n',sets{ii,1});
            case 'surfS2'
                fprintf(fid,'*Elset, elset=%s_S, internal\n',sets{ii,1});
                fprintf(fid,'%d, %d, %d\n',sets{ii,3});
                fprintf(fid,'\n');
                fprintf(fid,'*Surface, type=ELEMENT, name=%s\n',sets{ii,1});
                fprintf(fid,'%s_S, S2\n',sets{ii,1});
            case 'surfS1'
                fprintf(fid,'*Elset, elset=%s_S, internal\n',sets{ii,1});
                fprintf(fid,'%d, %d, %d\n',sets{ii,3});
                fprintf(fid,'\n');
                fprintf(fid,'*Surface, type=ELEMENT, name=%s\n',sets{ii,1});
                fprintf(fid,'%s_S, S1\n',sets{ii,1});
                %%%%% top is S3 bot is S1 - in tet
        end
    end
end

if size(material.name,1)==1 && ~iscell(material.name)
    fprintf(fid,'** Section: HomogeneousSection\n');
    fprintf(fid,'*Solid Section, elset=%sBodySet, material=%s\n,\n',part_id,material.name);
elseif iscell(material.name)
    for ii = 1:size(material.name)
        fprintf(fid,'** Section: HomogeneousSection\n');
        fprintf(fid,'*Solid Section, elset=%s, material=%s\n,\n',material.name{ii,1},material.name{ii,2});
    end
end

fprintf(fid,'*End Part\n');
fprintf(fid,'**\n');

end

