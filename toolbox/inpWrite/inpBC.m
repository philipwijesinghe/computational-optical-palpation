function [ ] = inpBC( fid, part, dofs, u, varargin )
%INPBC Writes boundary conditions to an entire part
%       only use this for rigid compression bodies
%
%   Use:
%       inpBC( fid, part, dof, u, part, dof, u, ... )
%
%   Inputs:
%       fid - handle to .inp file (use fopen)
%       part - part to constrain
%               if part is structure then part.name+bodyset is taken
%               if part is string then needs to be in the form:
%                       partnameAssembly.nodeset
%       dofs - which degrees of freedom to set
%                   'all', all dof are set
%                   array of size 1 to 3, listing dof by id, 
%                                   [from 1:Ux 2:Uy 3:Uz], eg [1,3]
%       u - sets all selected dof to this displacement
%       amp_name(optional) - assigns an amplitude (has to be predefined by
%               inpAmp();
%

fprintf(fid,'**\n** BOUNDARY CONDITIONS\n**\n');

if isstruct(part)
    fprintf(fid,'** Name: %s Type: Displacement/Rotation\n',[part.name 'BC']);
    if nargin<5
        fprintf(fid,'*Boundary\n');
    else
        amp = varargin{1};
        fprintf(fid,'*Boundary, amplitude=%s\n',amp);
    end
    if strcmp(dofs, 'all')
        dofs = [1,2,3];
    end
    for di = 1:length(dofs)
        dof = dofs(di);
        if u==0
            fprintf(fid,'%sAssembly.%sBodySet, %d, %d\n',part.name,part.name,dof,dof);
        else
            fprintf(fid,'%sAssembly.%sBodySet, %d, %d, %d\n',part.name,part.name,dof,dof,u);
        end
    end
else
    fprintf(fid,'** Name: %s Type: Displacement/Rotation\n',[part 'BC']);
    if nargin<5
        fprintf(fid,'*Boundary\n');
    else
        amp = varargin{1};
        fprintf(fid,'*Boundary, amplitude=%s\n',amp);
    end
    if strcmp(dofs, 'all')
        dofs = [1,2,3];
    end
    for di = 1:length(dofs)
        dof = dofs(di);
        if u==0
            fprintf(fid,'%s, %d, %d\n',part,dof,dof);
        else
            fprintf(fid,'%s, %d, %d, %d\n',part,dof,dof,u);
        end
    end
end


end