function obj = readODBexport( filepath, filename, instance, step, frame, varargin )
% Reads the output of an Abaqus simulation (.odb)
%   notes: 
%       COORD field output must be set in Abaqus 
%           (already done in inpWrite toolbox)
%       abaqus often changes instance names to full UPPERCASE
%
%   Inputs:
%       filepath - Abaqus work dir, or path to folder containing .odb file
%       filename - job/data name (name of the file)
%       instance - FEA assembly instance, eg 'LAYERASSEMBLY'
%       step - name of step defined in simulation, eg 'Preload'
%       frame - output frame (int), use -1 for last frame, 0 for first
%       reparse (optional) - true(default)/false, 
%                   true: reads .odb file and parses into a .txt file
%                   false: looks for existing intermediate .txt file
%                           only use false if running a second time (to
%                           speed up reading) 
%
%   Outputs: 
%       a structure 'obj' with fields:
%           obj.U - displacement (nodeNo, u1, u2, u3)
%           obj.S - stress tensor (elemNo, s11, s22, s33, s12, ...
%                                           s13, s23, intPoint)
%           obj.LE - strain tensor (elemNo, le11, le22, le33, le12, ...
%                                           le13, le23, intPoint)
%           obj.elem - element connectivity (elemNo, node1, node2, ...
%                                           ... node10)
%                       connectivity is padded with 0
%                       eg tet has 4 nodes, so node5->node10 will be 0
%           obj.node - node coordinates (nodeNo, x1, x2, x3)
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
%      	b.1.0  :  2016-01-06
%                 	reparse feature
%
if nargin>5
    reparse = varargin{1};
else
    reparse = true;
end

tmp_path = fileparts(mfilename('fullpath'));
%% Write query variables to python file 'var.py'
delete([tmp_path '\var.py']);
fid = fopen([tmp_path '\var.py'], 'w');
    fprintf(fid,'filepath = ''%s''\n',filepath);
    fprintf(fid,'filename = ''%s''\n',filename);
    fprintf(fid,'instance = ''%s''\n',instance);
    fprintf(fid,'step = ''%s''\n',step);
    fprintf(fid,'frame = %d\n',frame);
fclose(fid);

%% Execute ABAQUS/python script 'readODBexport.py' to read in .odb data
%  and export it to a collection of .txt files
if reparse
    cur_dir = pwd;
    cd(tmp_path)
    system(['abaqus cae ','noGUI','=readODBexport.py']);
    delete('abaqus.rpy*'); % clean up after abaqus
    cd(cur_dir)
end

%% Read back exported data
outname = [filename '_out'];
out_path = [filepath '\readODBexport\' outname];
% Locate files
fidCOORD = fopen([out_path '\' outname '_' step '_' num2str(frame)...
    '_' instance '_COORD.txt']);
fidS = fopen([out_path '\' outname '_' step '_' num2str(frame)...
    '_' instance '_S.txt']);
fidLE = fopen([out_path '\' outname '_' step '_' num2str(frame)...
    '_' instance '_LE.txt']);
fidU = fopen([out_path '\' outname '_' step '_' num2str(frame)...
    '_' instance '_U.txt']);
fidEL = fopen([out_path '\' outname '_' step '_' num2str(frame)...
    '_' instance '_EL.txt']);

%% Read back and rearrange into Matlab array
% Node
node = textscan(fidCOORD, '%f64 %f64 %f64 %f64', 'delimiter',' ');
obj.node = cell2mat(node(:,:));
obj.node = sortrows(obj.node,1);
% Element
elem = textscan(fidEL, '%d %d %d %d %d %d %d %d %d %d %d', 'delimiter',' ');
obj.elem = cell2mat(elem(:,:));
obj.elem = sortrows(obj.elem,1);
% Displacement
U = textscan(fidU, '%f64 %f64 %f64 %f64', 'delimiter',' ');
obj.U = cell2mat(U(:,:));
obj.U = sortrows(obj.U,1);
% Stress
S = textscan(fidS, '%f64 %f64 %f64 %f64 %f64 %f64 %f64 %f64', 'delimiter',' ');
obj.S = cell2mat(S(:,:));
obj.S = sortrows(obj.S,[1 8]);
% Strain
LE = textscan(fidLE, '%f64 %f64 %f64 %f64 %f64 %f64 %f64 %f64', 'delimiter',' ');
obj.LE = cell2mat(LE(:,:));
obj.LE = sortrows(obj.LE,[1 8]);


end