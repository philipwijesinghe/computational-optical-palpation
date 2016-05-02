function [ face ] = reorient_faces( node, face )
%REORIENT_FACES Checks and reorients faces such that they face away from
%the centre of the body volume
%
%   Debugging function
%
%   Inputs:
%       node – list of nodes: id,x,y,z
%       face – list of surface faces: id,n1,n2,n3,(n4)
%                   takes both quad and tri faces
%   Outputs:
%       node – list of nodes: id,x,y,z
%       face – list of surface faces: id,n1,n2,n3,(n4)
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

% number of face nodes
nfn = size(face,2);
% extract face nodal coordinates
face_coord = node(face',2:end);
% calculate face normal
face_v1 = face_coord(1:nfn:end,:)-face_coord(2:nfn:end,:);
face_v2 = face_coord(3:nfn:end,:)-face_coord(2:nfn:end,:);
face_n = cross(face_v1,face_v2,2);
%%% - block above to be moved to nargout>3 when debug removed
% calculate face centroid [x,y,z] by averaging over coordinates
face_cent = reshape(face_coord',3,nfn,[]);
face_cent = squeeze(mean(face_cent,2))';
% calculate vector from body center
face_vect = face_cent-repmat(mean(node(:,2:end)),[size(face_cent,1) 1]);
% calculate orientation
face_orient = sign(dot(face_vect,face_n,2));
% flip if needed
face(face_orient==-1,2:end)=fliplr(face(face_orient==-1,2:end));

sprintf('\nFace reorientation: Flipped %d faces\n\n',sum(face_orient==-1))

end

