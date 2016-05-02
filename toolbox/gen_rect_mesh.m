function [ node, elem, varargout ] = gen_rect_mesh( x,y,z,varargin)
%GEN_RECT_MESH Generates a 3D structured mesh of a rectangular body
%
%   Inputs:
%       x – size in x
%       y – size in y
%       z – size in z
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
%       opt.mesh_size = 0.5;
%       opt.mesh_type = 'hex';
%       [node,elem,face,top,bot] = gen_rect_mesh( 1,1,1,opt);
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
%       b.2.0  :  2015-05-06
%                   moved debug to separate functions
%      	b.1.0  :  2015-05-05
%                 	added debug
%     	a.1.0  :  2015-05-04
%                 	dev
%

%% User Inputs
% set body size
bsize = [x,y,z];
% parse/validate inputs
if nargin<4
    opt.mesh_size = 1/10*min(bsize);
    opt.mesh_type = 'tet';
else
    opt = varargin{1};
    if(isstruct(opt) && ~isfield(opt,'mesh_size'))
        opt.mesh_size = 1/10*min(bsize);
    elseif ~isnumeric(opt.mesh_size)
        fprintf('ERROR in gen_rect_mesh():\n opt.mesh_size incorrect - expected input to be a number');
        return
    elseif length(opt.mesh_size)~=1 && length(opt.mesh_size)~=3
        fprintf('ERROR in gen_rect_mesh():\n opt.mesh_size incorrect - expected input to be of length 1 or 3');
        return
    end
    if(isstruct(opt) && ~isfield(opt,'mesh_type'))
        opt.mesh_type = 'tet';
    else
        try
            opt.mesh_type = validatestring(opt.mesh_type,{'hex','tet'});
        catch
            fprintf('ERROR in gen_rect_mesh():\n opt.mesh_type incorrect - expected input to match: ''hex'' or ''tet'' ');
            return
        end
    end
end

%% Generate node list
% node spacing
nn = ceil(bsize./opt.mesh_size)+1;
x_loc = linspace(0,x,nn(1));
y_loc = linspace(0,y,nn(2));
z_loc = linspace(0,z,nn(3));
% generate node coordinates
[Yi,Xi,Zi] = meshgrid(y_loc,x_loc,z_loc); % matlab's 'yxz' notation - make x the short axis
% rearrange into table format
nid = 1:length(Xi(:));
node = [nid',Xi(:),Yi(:),Zi(:)];

%% Generate element list
% generate hex mesh -common for hex&tet
nn = single(nn);
% calculate total number of hex elements
ne = nn-1;
nehex = single(prod(ne));
elid = 1:nehex;
% generate positional indices
xi = mod(elid-1,ne(1))';
yi = floor(mod(elid-1,ne(1)*ne(2))/ne(1))';
zi = floor((elid-1)/(ne(1)*ne(2)))';
% generate element connectivity - canonical node ordering
elem = [    elid',...
    zi*nn(1)*nn(2)+yi*nn(1)+xi+1,...
    zi*nn(1)*nn(2)+yi*nn(1)+xi+2,...
    zi*nn(1)*nn(2)+(yi+1)*nn(1)+xi+2,...
    zi*nn(1)*nn(2)+(yi+1)*nn(1)+xi+1,...
    (zi+1)*nn(1)*nn(2)+yi*nn(1)+xi+1,...
    (zi+1)*nn(1)*nn(2)+yi*nn(1)+xi+2,...
    (zi+1)*nn(1)*nn(2)+(yi+1)*nn(1)+xi+2,...
    (zi+1)*nn(1)*nn(2)+(yi+1)*nn(1)+xi+1    ];

% generate tet elements if required
if strcmp(opt.mesh_type,'tet')
    % A hexahedron can be subdivided into 6 tetrahedrons
    netet = 6*nehex;
    tetid = (1:6:netet)';
    elem = sortrows([...
        [tetid,elem(:,[2,3,4,8])];
        [tetid+1,elem(:,[2,3,8,7])];
        [tetid+2,elem(:,[2,6,7,8])];
        [tetid+3,elem(:,[2,4,5,8])];
        [tetid+4,elem(:,[2,5,9,8])];
        [tetid+5,elem(:,[2,6,8,9])] ]);
end
%% Generate face list
if nargout>2
    % code modified from iso2mesh toolbox (http://iso2mesh.sf.net)
    switch opt.mesh_type
        case 'hex'
            % construct a set of all faces (6 times the number of hex elements)
            face = [   elem(:,[2,3,4,5]);
                elem(:,[2,5,9,6]);
                elem(:,[2,6,7,3]);
                elem(:,[3,7,8,4]);
                elem(:,[4,8,9,5]);
                elem(:,[6,9,8,7]) ];
        case 'tet'
            % construct a set of all faces (4 times the number of tet elements)
            face = [   elem(:,[2,3,4]);
                elem(:,[2,4,5]);
                elem(:,[3,2,5]);
                elem(:,[3,5,4]) ];
    end
    % closed faces are non-unique - however have different node order
    % - very ram hungry - re-evaluate in future
    facesort=sort(face,2);
    [~,ix,jx]=unique(facesort,'rows');
    % find the indices of the faces that are repated only once
    vec=histc(jx,1:max(jx));
    qx=1:length(vec==1);
    % create a set of all OPEN faces
    face=face(ix(qx(vec==1)),:);
    % sort for aestetics
    face = sortrows(face,1:3);
    % index the faces
    face = [(1:length(face))',face];
    % write out
    varargout{1} = face;
end

%% Generate sets
if nargout>3
    % Recover surface node sets
    top.node = node(node(:,4)==z,1);
    bot.node = node(node(:,4)==0,1);
    
    % Recover surface face sets
    nfn = size(face,2)-1;
    % extract face nodal coordinates
    face_coord = node(face(:,2:end)',2:end);
    % calculate face normal
    face_v1 = face_coord(1:nfn:end,:)-face_coord(2:nfn:end,:);
    face_v2 = face_coord(3:nfn:end,:)-face_coord(2:nfn:end,:);
    face_n = cross(face_v1,face_v2,2);
    % find co-planar surfaces
    top.surf = face(face_n(:,3)>0,1);
    bot.surf = face(face_n(:,3)<0,1);
    
    % Recover surface element sets
    % - by searching through elements whose faces touch the surface
    % number of nodes in an element
    nen = size(elem,2)-1;
    % find element coordinates
    elem_coord = node(elem(:,2:end)',2:end);
    elem_coord = reshape(elem_coord',3,nen,[]); %[elem node,coord xyz,elem id]
    % check if a node touches the surface
    top_eid = elem_coord(3,:,:)==z;
    top_eid = squeeze(sum(top_eid,2));
    bot_eid = elem_coord(3,:,:)==0;
    bot_eid = squeeze(sum(bot_eid,2));
    % pull indices of elements that have the same number of nodes
    % as in an equivalent face touching the surface
    top.elem = elem(top_eid==nfn,1);
    bot.elem = elem(bot_eid==nfn,1);
    
    % write to variable output
    varargout{2} = top;
    varargout{3} = bot;
end

% end function
end

