function [ orient ] = check_tetmesh( node, elem )
%CHECK_TETMESH Checks a tetrahedral mesh for correct orientation
%
%   Debugging function
%
%   Inputs:
%       node – list of nodes: id,x,y,z
%       elem – list of elements: id,n1,n2,n3,n4
%   Outputs:
%       orient - orientation: 1 correct, -1 negative volume
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
%      	b.1.0  :  2015-05-06
%                 	ready to implement
%

% check orientation
A = node(elem(:,2),2:end);
B = node(elem(:,3),2:end);
C = node(elem(:,4),2:end);
D = node(elem(:,5),2:end);
AB = B-A;
AD = D-A;
AC = C-A;
orient = sign(dot(AB,cross(AC,AD,2),2));

if min(orient)~=1
    sprintf('Incorrect tet orientation - check element node numbering')
end

end

