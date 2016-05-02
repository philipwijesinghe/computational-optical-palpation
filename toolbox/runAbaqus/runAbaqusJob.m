function [  ] = runAbaqusJob( work_dir, inp_path, data_name, RAM )
%RUNABAQUSJOB Runs Abaqus solver
%
%   Inputs:
%       work_dir - Abaqus working directory (stores intermediate files)
%       inp_path - path to .inp file
%       data_name - name of dataset (used to name output files)
%       RAM - maximum memory allocation for Abaqus (GBs)
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

tmp_path = fileparts(mfilename('fullpath'));
cur_dir = pwd;

inp_path = strrep(inp_path,'\','\\');

% create .py file
delete([tmp_path '\runJobVar.py']);
fid = fopen([tmp_path '\runJobVar.py'], 'w');
    fprintf(fid,'workDir = ''%s''\n',work_dir);
    fprintf(fid,'inpPath = ''%s''\n',inp_path);
    fprintf(fid,'dataName = ''%s''\n',data_name);
    fprintf(fid,'RAM = %d\n',RAM);
fclose(fid);

% run
cd(tmp_path)
system(['abaqus cae ','noGUI','=runJob.py']);
delete('abaqus.rpy*'); % clean up after abaqus
cd(cur_dir)

end

