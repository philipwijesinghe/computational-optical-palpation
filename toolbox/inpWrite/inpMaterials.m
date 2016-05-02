function [ ] = inpMaterials( fid, varargin )
%INPMATERIALS
% parse for correct input
%
% required:
%   varargin - n structures with entries
%       var.material.name = 'name'
%
%           elastic
%       var.material.E = num +ive
%       var.material.v = num [0 0.5]
%       OR
%           hyperelastic
%       var.material.C10 = num
%       var.material.C01 = num
%       var.material.D = num
%
%           OR for multi-material parts
%       var.material.name = {'set id','name1';...
%                     'set id','name2'};
%       var.material.E = {numE1,numE2};
%       var.material.v = {numv1,numv2};
%
% Example:
%   act.material.name = 'actMaterial';
%   act.material.E = 10000;
%   act.material.v = 0.2;
%   % Example of multi-partitioned material assignment
%   sample.material.name = {'sampleBulkSet','sampleBulkMaterial';...
%                           'sampleIncSet','sampleIncMaterial'};
%   sample.material.E = {10,100};
%   sample.material.v = {0.485,0.485};


fprintf(fid,'**\n** MATERIALS\n**\n');

for mi = 1:nargin-1
    var = varargin{mi}.material;
    if size(var.name,1)==1 && ~iscell(var.name)
        fprintf(fid,'*Material, name=%s\n',var.name);
        fprintf(fid,'*Density\n1e-09,\n');
        % write as elastic or hyperelastic
        if isfield(var,'E') && isfield(var,'v') && ~isfield(var,'C10')
            fprintf(fid,'*Elastic\n');
            fprintf(fid,'%11g, %11g\n',var.E,var.v);
        elseif ~isfield(var,'E') && isfield(var,'C10') && isfield(var,'C01') && isfield(var,'D')
            fprintf(fid,'*Hyperelastic, mooney-rivlin\n');
            fprintf(fid,'%11g, %11g, %11g\n',var.C10,var.C01,var.D);
        end
    elseif iscell(var.name)
        for pi=1:size(var.name,1)
            fprintf(fid,'*Material, name=%s\n',var.name{pi,2});
            fprintf(fid,'*Density\n1e-09,\n');
            % write as elastic or hyperelastic
            if isfield(var,'E') && isfield(var,'v') && ~isfield(var,'C10')
                fprintf(fid,'*Elastic\n');
                fprintf(fid,'%11g, %11g\n',var.E{pi},var.v{pi});
            elseif ~isfield(var,'E') && isfield(var,'C10') && isfield(var,'C01') && isfield(var,'D')
                fprintf(fid,'*Hyperelastic, mooney-rivlin\n');
                fprintf(fid,'%11g, %11g, %11g\n',var.C10{pi},var.C01{pi},var.D{pi});
            end
        end
    end
end

end


