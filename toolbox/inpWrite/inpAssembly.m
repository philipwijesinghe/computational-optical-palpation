function [ ] = inpAssembly( fid, varargin )
%INP ASSEMBLY Create part instances in the FEA assembly
%   
%   Use: inpAssembly( fid, part1, part2, part3, ... )
%
%   Inputs
%       fid - handle to .inp file (use fopen)
%       varargin - n number of structures
%           partN, with at least the field
%               partN.name - part name (will generate assembly called:
%                                           'partnameAssembly'
%
%   Example: 
%       inpAssembly( fid, imp, layer, rf)
%       

fprintf(fid,'**\n** ASSEMBLY\n**\n*Assembly, name=Assembly\n**\n');
for ai = 1:nargin-1
    var = varargin{ai};
    fprintf(fid,'*Instance, name=%sAssembly, part=%s\n',var.name,var.name);
    fprintf(fid,'*End Instance\n**\n');
end
fprintf(fid,'*End Assembly\n');

end


