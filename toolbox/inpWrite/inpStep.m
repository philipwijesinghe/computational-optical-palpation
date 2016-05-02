function [ ] = inpStep( fid, name, type, varargin )
%INPSTEP Write step definition to Abaqus .inp file
%   Currently supports static, general and dynamic,explicit
%
%   Inputs:
%       fid - file id (as set by fopen)
%       name - step name
%       type - 'standard' or 'explicit' step type
%       scale_factor(optional) - mass scaling factor for explicit
%

if nargin==4
    scale_factor = varargin{1};
else
    scale_factor = 25;
end
    

fprintf(fid,'** -----------------------------------------------\n');
fprintf(fid,'**\n** STEP: %s\n**\n',name);
fprintf(fid,'*Step, name=%s, nlgeom=YES\n',name);
switch type
    case 'standard' % static, general step
        fprintf(fid,'*Static\n');
        fprintf(fid,'0.01, 1., 1e-05, 0.1\n'); % start, max, min (time step), step time
    case 'explicit' % dynamic, explicit step
        fprintf(fid,'*Dynamic, Explicit\n');
        fprintf(fid,', 1.\n'); % empty, step time, empty, max time increment
        fprintf(fid,'*Bulk Viscosity\n');
        fprintf(fid,'0.06, 1.2\n'); % linear, quadratic (viscosity param)
%         fprintf(fid,'*Dload\n');
%         fprintf(fid,'layerAssembly.layerBodySet, VP, 0.1\n');
        fprintf(fid,'*Fixed Mass Scaling, factor=%d\n',scale_factor);
        
end

end

