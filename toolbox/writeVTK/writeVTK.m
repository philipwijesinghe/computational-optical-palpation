function [ ] = writeVTK( fid, node, elem, varargin)
%WRITEVTK Writes FEA output to VTK format 
%for visualization with PARAVIEW
%   fid,node,elem,disp,U
%   so far very basic - single use

% Write header and metadata
fprintf(fid,'# vtk DataFile Version 2.0\n');
fprintf(fid,'writeVTK_out\n');
fprintf(fid,'ASCII\n');
fprintf(fid,'\n');
%

% IF unctructured grid polydata
fprintf(fid,'DATASET UNSTRUCTURED_GRID\n');

% Define points as x y z
fprintf(fid,'POINTS %i float\n',size(node,1));
for nn = 1:size(node,1)
    fprintf(fid,'%f %f %f\n',node(nn,2:end));
end
fprintf(fid,'\n');

% Define cells and cell connectivity
fprintf(fid,'CELLS %i %i\n',size(elem,1),size(elem,1)*9);
for nn = 1:size(elem,1)
    fprintf(fid,'8 %i %i %i %i %i %i %i %i\n',elem(nn,2:9)-1);
end
fprintf(fid,'\n');

% Assign each cell a cell type (12 is hexahedral unstructured)
fprintf(fid,'CELL_TYPES %i\n',size(elem,1));
for nn = 1:size(elem,1)
    fprintf(fid,'12\n');
end
fprintf(fid,'\n');

%% Assign fields to points or cells

%% POINT DATA
if nargin >= 4
    disp = varargin{1};
    fprintf(fid,'POINT_DATA %i\n',size(node,1));
    % fprintf(fid,'SCALARS scalars float 1\n');
    % fprintf(fid,'LOOKUP_TABLE default\n');
    % for nn = 1:size(node,1)
    %     fprintf(fid,'%f\n',disp(nn,4));
    % end
    % fprintf(fid,'\n');
    
    fprintf(fid,'VECTORS disp float\n');
    for nn = 1:size(node,1)
        fprintf(fid,'%f %f %f\n',disp(nn,2),disp(nn,3),disp(nn,4));
    end
    fprintf(fid,'\n');
    
end

%% CELL DATA
if nargin >=5
    LE = varargin{2};
    % format of LE = [11,22,33,12,13,23]
    
    fprintf(fid,'CELL_DATA %i\n',size(elem,1));
       
    % fprintf(fid,'TENSORS tensors float\n');
    % for nn = 1:size(elem,1)
    %     fprintf(fid,'%f %f %f\n',LE(nn,1),LE(nn,4),LE(nn,5));
    %     fprintf(fid,'%f %f %f\n',LE(nn,4),LE(nn,2),LE(nn,6));
    %     fprintf(fid,'%f %f %f\n',LE(nn,5),LE(nn,6),LE(nn,3));
    %     fprintf(fid,'\n');
    % end
    % fprintf(fid,'\n');
       
    % Calculate min principal vector (we are looking for principal
    % compression)
    fprintf(fid,'VECTORS strain float\n');
    for nn = 1:size(elem,1)
        tens = [LE(nn,1),LE(nn,4),LE(nn,5);...
            LE(nn,4),LE(nn,2),LE(nn,6);...
            LE(nn,5),LE(nn,6),LE(nn,3)];
        [V,D] = eig(tens);
        [C,I] = min(sum(D,1));
        CV = C.*V(:,I);
        fprintf(fid,'%f %f %f\n',CV(1),CV(2),CV(3));
    end
    fprintf(fid,'\n');
    
end

% ~~~ end function
end

