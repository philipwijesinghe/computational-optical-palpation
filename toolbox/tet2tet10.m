function [ model ] = tet2tet10( model )
%TET2TET10 Coverts 4-node tet model to 10-node tet model
%   Note: Does not convert 3-node faces to 6-node faces (currently not
%   required)
%
%   Inputs:
%       model – structure:
%               model.node – list of nodes: id,x,y,z
%               model.elem – list of elements: id,n1,n2...(n8 -hex)
%               model.top – structure:
%                   model.top.node - list of node id's of the top (z+) surface
%               model.bot – same as above for the bottom (z-) surface
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
%     	a.1.0  :  2015-06-25
%                 	dev
%
fprintf('Reindexing tet4 elements as tet10\n')

nn = length(model.node(:,1));
ne = length(model.elem(:,1));
for eli = 1:ne
    % query element node coordinates
    elcon = model.node(model.elem(eli,2:end),2:end);
    % generate 6 extra nodes for tet 10
    new = [  (elcon(2,:)+elcon(1,:))/2;...%5
                (elcon(3,:)+elcon(2,:))/2;...%6
                (elcon(3,:)+elcon(1,:))/2;...%7
                (elcon(4,:)+elcon(1,:))/2;...%8
                (elcon(4,:)+elcon(2,:))/2;...%9
                (elcon(4,:)+elcon(3,:))/2 ]; %10
    % append to nodelist
    if eli==1
        append_node=new;
    else
        % method too slow - but less ram - reconsider for large nelems
            % [Lia,Loib] = ismember(new,append_node,'rows');
            % elem_idx = Loib+length(append_node)*(~Lia)+cumsum(~Lia);
            % append_node = [append_node;new(~Lia,:)];
        append_node = [append_node;new];
    end
    if mod(eli,10000)==0
        fprintf('-- Reindexed %dk elements out of %dk\n',floor(eli/1000),ceil(ne/1000));
    end
end

% check for node uniqueness]
[append_node, ~, ic] = unique(append_node, 'rows');
% reindex elements
elem_idx = reshape(ic,6,[])' + nn;

% reform node list
model.node = [model.node(:,2:end);append_node];
nnn = length(model.node(:,1));
model.node = [(1:nnn)',model.node];
fprintf('- Reindexing Complete: new number of nodes = %d\n\n', nnn);

% reform element list
model.elem  = [model.elem,elem_idx];

% recalculate node sets
z = model.node(model.top.node(1),4);
model.top.node = model.node((model.node(:,4)==z),1);
model.bot.node = model.node((model.node(:,4)==0),1);

end






