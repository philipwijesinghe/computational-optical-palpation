function [node,elem,face,top,bot] = mesh_thin_plane(z,dz,x,y,varargin)
%MESH_THIN_PLANE meshes a thin shell-like plane as an uneven surface
%
%   Inputs:
%       z - z-pozition of the plane
%       dz - plane thickness (single thickness number)
%       x – size in x
%       y – size in y
%       opt – structure:
%           opt.mesh_size – specifies mesh size,
%                           isotropic if length=1, in [x,y,z] if length=3;
%                           (default) 1/10 min size
%           opt.mesh_type – {‘hex’,’tet’} specifies either hexagonal
%                           meshing or tetrahedral (default) meshing
%   Outputs:
%       node – list of nodes: id,x,y,z
%       elem – list of elements: id,n1,n2...(n4 -tet or n8 -hex)
%       face – list of surface faces: id,n1,n2,n3,(n4)
%       top – structure:
%           top.node - list of node id's
%           top.surf - list of surface id's
%           top.elem - list of element id's
%                           of the top (z+) surface
%       bot – same as above for the bottom (z-) surface
%
%   Examples:
%
%   Info:
%       Version: 1.0.0
%       Date: 2016-05-02
%       Author: Philip Wijesinghe
%       Email: philip.wijesinghe@gmail.com
%
%       Changelog:
%       1.0.0  :  2016-05-02 
%                   public release
%     	a.1.0  :  2015-05-06
%                 	dev
%

%% User Input
% parse/validate input
if nargin<4
    opt.mesh_size = 1/10*min(bsize);
    opt.mesh_type = 'tet';
else
    opt = varargin{1};
    if(isstruct(opt) && ~isfield(opt,'mesh_size'))
        opt.mesh_size = 1/10*min(bsize);
    elseif ~isnumeric(opt.mesh_size)
        sprintf('ERROR in mesh_rect_struct():\n opt.mesh_size incorrect - expected input to be a number')
        return
    elseif length(opt.mesh_size)~=1 && length(opt.mesh_size)~=3
        sprintf('ERROR in mesh_rect_struct():\n opt.mesh_size incorrect - expected input to be of length 1 or 3')
        return
    end
    if(isstruct(opt) && ~isfield(opt,'mesh_type'))
        opt.mesh_type = 'tet';
    else
        try
            opt.mesh_type = validatestring(opt.mesh_type,{'hex','tet'});
        catch
            sprintf('ERROR in gen_rect_mesh():\n opt.mesh_type incorrect - expected input to match: ''hex'' or ''tet'' ')
            return
        end
    end
end

%% Generate a mesh for a regular rectangle
fprintf('Generating structured mesh\n');
% of z thikness
[node,elem,face,top,bot] = gen_rect_mesh(x,y,dz,opt);

fprintf(' - Mesh generation complete:\n');
fprintf(' -- %d nodes; %d elements\n\n',length(node(:,1)),length(elem(:,1)) );


%% Scale mesh z value based on L0
% z distortion scale factor
dimL = size(z);
% interpolate for actual x and y nodal coordinates 
[X,Y] = meshgrid(linspace(0,x,dimL(2)),linspace(0,y,dimL(1)));
z_n = interp2(X,Y,z,node(:,2),node(:,3),'cubic');
% apply scaling
node(:,4) = node(:,4)+z_n;


end

