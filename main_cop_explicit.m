function [ T ] = main_cop_explicit( meta, L0, Lp, material, varargin )
%MAIN_COP_EXPLICIT carries out computational optical palpation
%
%   Notes:
%
%   Inputs:
%       meta - structure
%           meta.job - job name
%           meta.model - model name
%           meta.gen - 'generated by' name
%               (names not critical)
%           meta.output_path - output path (make sure folder exists)
%           meta.abaqus_work_dir - path to Abaqus work dir
%       L0 - initial thickness of the layer: 
%           either single number for a constant layer size, or
%           nx by ny for uneven layer size (same size as Lp, mm)
%       Lp - preloaded thickness of the layer:
%           nx by ny (mm)
%       material - structure:
%           material.C10 - mooney-rivlin coefficient
%           material.C01 -          "           
%       opt  structure:
%           opt.size  specifies layer size (or FOV)
%                          [x y] (mm)
%           opt.mesh.mesh_type  {hex,tet,'tet10'} specifies either hexagonal
%                           meshing or tetrahedral (default) meshing or
%                           10-node tetrahedral meshing
%           opt.mesh.mesh_size  specifies mesh size,
%                           isotropic if length=1, in [x,y,z] if length=3;
%                           (default) 1/10 min size
%           opt.mesh.elem_type - 
%           opt.frict.plate - friction coefficient of layer with plate
%           opt.frict.sample - friction coefficient of layer with sample
%
%   Outputs:
%       T - surface traction forces (projection onto z-plane)
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
%     	a.1.0  :  2015-06-30
%                 	dev
%
%%

%% Check inputs
if nargin<5
    opt.size = [5,5];
    opt.mesh.mesh_type = 'hex';
    opt.mesh.elem_type = 'C3D8';
    opt.mesh.mesh_size = 0.1;
    opt.frict.plate = 0.3;
    opt.frict.sample = 0.1;
else
    opt = varargin{1};
end %check structure contains fields

%% Debug
debug=0;
if debug
    L0 = 0.5;
    Lp = preload_thickness;
    material = layer.material;
    opt.size = [5,5];
    opt.mesh.mesh_type = 'hex';
    opt.mesh.elem_type = 'C3D8';
    opt.mesh.mesh_size = 0.125;
    opt.frict.plate = 0.15;
    opt.frict.sample = 0.001;
    %% Meta data
    meta.job = 'COP_job_default';
    meta.model = 'Model-1';
    meta.gen = 'computational QOCE toolbox';
    meta.output_path =  'E:\OBEL\Matlab scripts\project\computational_QOCE\test_outputs';
    meta.abaqus_work_dir = 'C:\Users\Philip\Documents\Abaqus';
end

%% Main
output_path = meta.output_path;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Assign input properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Imprint body
imp.name = 'imp';
imp.material.name = 'impMaterial';
% -rigid structure (note: material irrelevant, stucture doesn't deform)
imp.material.E = 0.001; %MPa
imp.material.v = 0;
imp.mesh = opt.mesh;
imp.mesh.elem_type = 'C3D8R';

% Layer body
layer.name = 'layer';
layer.material.name = 'layerMaterial';
layer.material.C10 = material.C10;
layer.material.C01 = material.C01;
layer.material.D = 0;
layer.mesh = opt.mesh;

% Reaction force - bottom plate
rf.name = 'rf';
rf.L0 = mean(L0(:));
rf.x = opt.size(1)+4;
rf.y = opt.size(2)+4;
rf.mesh.mesh_size = 2; 
rf.mesh.mesh_type = 'hex';
rf.mesh.elem_type = 'C3D8R';
rf.material.name = 'rfMaterial';
rf.material.E = 1;
rf.material.v = 0;

% Supporting geometry parameters
int.d0 = 0.01; %mm - initial separation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate meshes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate layer mesh
% [nx,ny] = meshgrid(linspace(0,opt.size(1),size(Lp,1)),linspace(0,opt.size(2),size(Lp,2)));
[layer.node,layer.elem,layer.face,layer.top,layer.bot] = ...
    mesh_rect_struct(L0,opt.size(1),opt.size(2),opt.mesh);
fprintf('Generated: %s Part with %d elements\n\n','layer',length(layer.elem(:,1)));

% Generate sample imprint mesh
%   -find the offset as highest layer point to lowest sample imprint
[imp.node,imp.elem,imp.face,imp.top,imp.bot] = ...
    mesh_rect_struct(imp.mesh.mesh_size,opt.size(1)+2,opt.size(2)+2,imp.mesh);
fprintf('Generated: %s Part with %d elements\n\n','sample imprint',length(imp.elem(:,1)));
imp.node(:,4) = imp.node(:,4)+max(L0(:))+int.d0;
imp.node(:,2:3) = imp.node(:,2:3) - 1;

% Generate bottom plate (reaction forces)
[rf.node,rf.elem,rf.face,rf.top,rf.bot] = ...
    mesh_rect_struct(rf.L0,rf.x,rf.y,rf.mesh);
fprintf('Generated: %s Part with %d elements\n\n',rf.name,length(rf.elem(:,1)));
rf.node(:,4) = rf.node(:,4)-max(rf.node(:,4));
rf.node(:,2:3) = rf.node(:,2:3) - 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Assign sets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% surface assignment is currently somewhat arbitrary. A surface is defined
% as an element number and then a face number (e.g., a tet element will have 4
% sides S1-S4). Now you have to guess which side you want based on the
% geometry. This will be constant for similar geometries. In the future
% this should be replaced by an automated search for free sides.

% tet: sides S1(bot) S3(top); hex: sides S1(bot) S2(top)
imp.sets = {'impTopSet','node',imp.top.node;...
    'impTopSet','elem',imp.top.elem;...
    'impBotSet','node',imp.bot.node;...
    'impBotSet','elem',imp.bot.elem;...
    'impTopSurf','surfS2',imp.top.elem;...
    'impBotSurf','surfS1',imp.bot.elem };
layer.sets = {'layerTopSet','node',layer.top.node;...
    'layerTopSet','elem',layer.top.elem;...
    'layerBotSet','node',layer.bot.node;...
    'layerBotSet','elem',layer.bot.elem;...
    'layerTopSurf','surfS2',layer.top.elem;...
    'layerBotSurf','surfS1',layer.bot.elem };
rf.sets = {'rfTopSurf','surfS2',rf.top.elem;...
    'rfBotSurf','surfS1',rf.bot.elem };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interaction properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int.prop{1}.name = 'layerImpIntProp';
int.prop{1}.frict = opt.frict.sample;
int.prop{1}.po = 'EXPONENTIAL'; %pressure-overclosure
int.prop{1}.e1 = 0.01;
int.prop{1}.e2 = 2;
int.prop{2}.name = 'rigidIntProp';
int.prop{2}.frict = opt.frict.plate;
int.prop{2}.po = 'HARD';

int.pair={};
int.pair{end+1}.name = 'layerSampleInt1';
int.pair{end}.prop = int.prop{1}.name;
int.pair{end}.m = 'impAssembly.impBotSurf'; % master surf
int.pair{end}.s = 'layerAssembly.layerTopSurf'; % slave surf
int.pair{end+1}.name = 'rfInt';
int.pair{end}.prop = int.prop{2}.name;
int.pair{end}.m = 'rfAssembly.rfTopSurf'; % master surf
int.pair{end}.s = 'layerAssembly.layerBotSurf'; % slave surf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Evaluate nodal displacement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate displacement
dimL = size(Lp);
Uz = Lp - (max(L0(:)));
Uz = double(Uz);

% Check if 'gridfit' function exists
if ~exist('gridfit','file')
    fprintf('********************************************** \n');
    fprintf('Missing gridfit.m function, \n');
    fprintf('please download from: \n');
    fprintf('http://au.mathworks.com/matlabcentral/fileexchange/8998-surface-fitting-using-gridfit \n');
    fprintf('********************************************** \n');
    return
end

% Interpolate for actual x and y nodal coordinates
[X,Y] = meshgrid(linspace(0,opt.size(1),dimL(2)),linspace(0,opt.size(2),dimL(1)));
% --interpolate, padding the edges to remove sharp boundaries
xe = [repmat(-1,[1 10]), linspace(-1,opt.size(1)+1,10),repmat(opt.size(1)+1,[1 10]),linspace(opt.size(1)+1,-1,10)];
ye = [linspace(-1,opt.size(2)+1,10),repmat(opt.size(2)+1,[1 10]),linspace(opt.size(2)+1,-1,10),repmat(-1,[1 10])];    
[Uzn,xg,yg] = gridfit([X(:); xe(:)],[Y(:); ye(:)],[Uz(:); repmat(mean(Uz(:)),[length(xe(:)) 1])],...
    linspace(-1,opt.size(1)+1,dimL(1)*2),linspace(-1,opt.size(2)+1,dimL(2)*2),...
    'smoothness',3,'tilesize',500);
% --find individual nodal displacement
Uzn = interp2(xg,yg,Uzn,imp.node(imp.bot.node,2),imp.node(imp.bot.node,3),'cubic');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define amplitudes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

amp.name = 'amp-1';
% tabular amplitude difinition: [time, amp; time, amp; ... ]
amp.table = [0,0; 1,1];
% reshape into Abaqus format
amp.table = reshape(amp.table',1,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Write to INP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inp_path = [output_path '\' meta.job '.inp'];
fid = fopen(inp_path,'w');
% write HEADER
inpHeader( fid, meta )
% write PART
inpPart( fid, imp.name, imp.node, imp.elem , imp.mesh, imp.material, imp.sets)
inpPart( fid, layer.name, layer.node, layer.elem , layer.mesh, layer.material, layer.sets)
inpPart( fid, rf.name, rf.node, rf.elem , rf.mesh, rf.material, rf.sets)
% write MATERIALS
inpMaterials( fid, imp, layer, rf)
% write ASSEMBLY
inpAssembly( fid, imp, layer, rf)
% write Amplitudes
inpAmp( fid, amp )

%STEP by STEP defn
% write INTS
inpIntProp( fid, int )

% Fixed boundary conditions - only disp.rot atm
% !!! this will break if part is partitioned w/o a 'BodySet'
inpBC( fid, rf, 'all', 0);
inpBC( fid, imp, [1,2], 0);
% ---------------------------------------------
% write STEP1 - static, internally defined atm
inpStep( fid, 'Preload', 'explicit' )
% write INTS
inpInts( fid, int, 'explicit' )
% write BC's
% inpBCnodal( fid, 'impAssembly', imp.node(:,1), Lpn, amp.name)
inpBCnodal( fid, 'impAssembly', imp.node(imp.bot.node,1), Uzn, amp.name)
% inpBCnodal( fid, 'impAssembly', imp.node(nci,1), Lpn)
% write OUTPUTS
inpOutput( fid, 'explicit' )
% end step
fprintf(fid,'*End Step\n');
% ---------------------------------------------

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run Abaqus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n***** RUNNING ABAQUS\n\n');
fprintf('Open .sta file in ABAQUS work dir for job status\n\n');

runAbaqusJob( meta.abaqus_work_dir, inp_path, meta.job, 10 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n***** READING RESULTS\n\n');

instance = 'LAYERASSEMBLY';
step = 'Preload';
frame = 0;
layer.out.preload{1} = readODBexport( meta.abaqus_work_dir,meta.job,instance,step,frame);
frame = -1;
layer.out.preload{2} = readODBexport( meta.abaqus_work_dir,meta.job,instance,step,frame);

%% Queery enface x y indices
[xq,yq]=meshgrid(linspace(0,opt.size(1),1000),linspace(0,opt.size(2),1000));

%% Extract stress
% Preload
% -find element centroid at preload
elcp = layer.out.preload{2}.node(layer.out.preload{2}.elem(layer.top.elem,2:9)',2:end);
elcp = reshape(elcp',3,8,[]);
elcp = squeeze(mean(elcp,2))';
% -average stress over integration points
nIntPoints = max(layer.out.preload{2}.S(:,8));
Sp = layer.out.preload{2}.S(:,2:7);
Sp = reshape(Sp',6,nIntPoints,[]);
Spm = squeeze(mean(Sp,2))';
Spm = Spm(layer.top.elem,:);

cop_stress_xy = griddata(elcp(:,1),elcp(:,2),Spm(:,3),xq,yq);
% figure;imagesc(cop_stress_xy);
% colormap(gray);caxis([-0.007 0]);axis image;colorbar;

%% Output
T = cop_stress_xy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
