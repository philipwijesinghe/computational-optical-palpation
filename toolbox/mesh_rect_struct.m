function [node,elem,face,top,bot] = mesh_rect_struct(L0,x,y,varargin)
%MESH_RECT_STRUCT meshes a rectangular body with a single uneven surface at
%       z+ surface, specified by L0
%
%   Notes:
%       Do not use the default 4-node tetrahedral 'tet' meshing for 3D
%       deformation modelling, these elements are linear - very stiff and
%       thus do not produce accurate results, especially at the surfaces.
%       'hex' elements are prefferable but may cause non-convergence and
%       hourglassing - in which case 10-node tetrahedral 'tet10' elements
%       should be used.
%
%   Inputs:
%       L0 - thickness of the body in z (2D matrix [x,y]),
%               if L0 is 1 number, then a constant z is used
%       x – size in x
%       y – size in y
%       opt – structure:
%           opt.mesh_size – specifies mesh size,
%                           isotropic if length=1, in [x,y,z] if length=3;
%                           (default) 1/10 min size
%           opt.mesh_type – {‘hex’,’tet’,'tet10'} specifies either hexagonal
%                           meshing or tetrahedral (default) meshing or
%                           10-node tetrahedral meshing
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
%       b.1.0  :  2015-06-25
%                   finalised; added tet10
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
            opt.mesh_type = validatestring(opt.mesh_type,{'hex','tet','tet10'});
        catch
            sprintf('ERROR in gen_rect_mesh():\n opt.mesh_type incorrect - expected input to match: ''hex'' or ''tet'' ')
            return
        end
    end
end

%% Generate a mesh for a regular rectangle
fprintf('Generating structured mesh\n');
% of z thikness
z = mean(L0(:));
opt_g = opt;
if strcmp(opt.mesh_type,'tet10')
    opt_g.mesh_type = 'tet';
end
[node,elem,face,top,bot] = gen_rect_mesh(x,y,z,opt_g);

fprintf(' - Mesh generation complete:\n');
fprintf(' -- %d nodes; %d elements\n\n',length(node(:,1)),length(elem(:,1)) );

%% Reindex as tet10 if required
if strcmp(opt.mesh_type,'tet10')
    % does not reindex 2D face elements
    model.node=node;model.elem=elem;model.top=top;model.bot=bot;
    model = tet2tet10( model );
    node=model.node;elem=model.elem;top=model.top;bot=model.bot;
end

% just return the values if a uniform L0 is desired
if length(L0)==1
    return
end

%% Scale mesh z value based on L0
% z distortion scale factor
z_sf = L0/z;
dimL = size(L0);
% interpolate for actual x and y nodal coordinates
[X,Y] = meshgrid(linspace(0,x,dimL(2)),linspace(0,y,dimL(1)));
zn_sf = interp2(X,Y,z_sf,node(:,2),node(:,3),'cubic');
% apply scaling
node(:,4) = node(:,4).*zn_sf;

end

