%% Example script for computational optical palpation
% Add to path
addpath(genpath('../computational-optical-palpation/'));

%% User Input
% Meta data
meta.job = 'COP_job_example';
meta.model = 'Model-1';
meta.gen = 'computational QOCE toolbox';
meta.output_path =  'E:\OBEL\Matlab scripts\project\computational_QOCE\test_outputs';
meta.abaqus_work_dir = 'C:\Users\Philip\Documents\Abaqus';
% Thickness data
L0 = 0.5;
load('coin_5c_1-thickness.mat');
Lp = in_L0;
% Material
material.C10 = 0.0022;
material.C01 = 7.03E-4;
% Meshing
opt.size = [5,5];
opt.mesh.mesh_type = 'hex';
opt.mesh.elem_type = 'C3D8';
opt.mesh.mesh_size = 0.125;
% Friction
opt.frict.plate = 0.15;
opt.frict.sample = 0.001;

%% Run COP
T = main_cop_explicit( meta, L0, Lp, material, opt );

%% Visualise Results
figure;imagesc(T);colormap(gray(256));
