function [ThermalCorrected,Scale] = ThermalImageCorrectionSurface(RGB,Thermal)
%%%% Input: pair of RGB and thermal images
%%%% Output: Calibrate thermal image and the calculated scales between physical and pixel dimension
%%%% Author: Cheng Zhang
%%%% Date: 9/14/2023

I = RGB;
tagFamily = ["tag36h11"];

[id,loc,detectedFamily] = readAprilTag(I,tagFamily);

% for idx = 1:length(id)
%         % Display the ID and tag family
%         disp("Detected Tag ID, Family: " + id(idx) + ", " ...
%             + detectedFamily(idx));
% 
%         % Insert markers to indicate the locations
%         markerRadius = 8;
%         numCorners = size(loc,1);
%         markerPosition = [loc(:,:,idx),repmat(markerRadius,numCorners,1)];
%         I = insertShape(I,"FilledCircle",markerPosition,Color="red",Opacity=1);
% end

%Detect centre of the four tag
tagCentre1 = [];
for i = 1:size(loc,3)
    tagCentre1(i,:) = [mean(loc(:,1,i)),mean(loc(:,2,i)),i];
end

tagCentre = sortrows(tagCentre1,1,'descend');

tagCentre_mean = [mean(tagCentre(1:4,1)),mean(tagCentre(1:4,2))];

CornerPoints = zeros(4,2);
for i = 1:4 % extract the four conner of Apriltag
    if tagCentre(i,1) > tagCentre_mean(1,1) && tagCentre(i,2) > tagCentre_mean(1,2)
        CornerPoints(1,:) = loc(3,:,tagCentre(i,3));
    elseif tagCentre(i,1) > tagCentre_mean(1,1) && tagCentre(i,2) < tagCentre_mean(1,2)
        CornerPoints(2,:) = loc(4,:,tagCentre(i,3));
    elseif tagCentre(i,1) < tagCentre_mean(1,1) && tagCentre(i,2) < tagCentre_mean(1,2)
        CornerPoints(3,:) = loc(1,:,tagCentre(i,3));
    elseif tagCentre(i,1) < tagCentre_mean(1,1) && tagCentre(i,2) > tagCentre_mean(1,2)
        CornerPoints(4,:) = loc(2,:,tagCentre(i,3));
    end
end

% Insert markers to indicate the locations
markerRadius = 8;
numCorners = size(loc,1);
markerPosition = [CornerPoints(:,:),repmat(markerRadius,numCorners,1)];
I = insertShape(I,"FilledCircle",markerPosition,Color="red",Opacity=1);

figure
imshow(I)

%% Calculate Apriltag location in thermal image
H_RANSAC = [0.201594	0.00154281	-64.2534
-0.000155454	0.190959	-39.2384
-2.12844e-06	-8.73168e-08	1];

TagCornerThernal = zeros(4,2);
for i = 1:4
    IR_P_x = (CornerPoints(i,1)*H_RANSAC(1,1) + CornerPoints(i,2)*H_RANSAC(1,2) + H_RANSAC(1,3))/(CornerPoints(i,1)*H_RANSAC(3,1) + CornerPoints(i,2)*H_RANSAC(3,2) + H_RANSAC(3,3));
    IR_P_y = (CornerPoints(i,1)*H_RANSAC(2,1) + CornerPoints(i,2)*H_RANSAC(2,2) + H_RANSAC(2,3))/(CornerPoints(i,1)*H_RANSAC(3,1) + CornerPoints(i,2)*H_RANSAC(3,2) + H_RANSAC(3,3));
    TagCornerThernal(i,:) = [IR_P_x,IR_P_y];
end

%% Conduct perspective transformation to calibrate thermal image
img= Thermal;
[M N ~] = size(img);

w=round(sqrt((TagCornerThernal(3,1)-TagCornerThernal(2,1))^2+(TagCornerThernal(3,2)-TagCornerThernal(2,2))^2));     %Calculate the width of the Apriltag
h=round(sqrt((TagCornerThernal(1,1)-TagCornerThernal(2,1))^2+(TagCornerThernal(1,2)-TagCornerThernal(2,2))^2));     %Calculate the height of the Apriltag
hw = mean([w,h]);

%Scale = 225/hw; % physical(mm)/pixel dimension, actual dimension of Apriltag is 225mm
Scale = 112.5/hw; % physical(mm)/pixel dimension, actual dimension of Apriltag is 112.5mm

% Calculate the projected CornerPoints
CornerPointsNew = [TagCornerThernal(3,1)+hw TagCornerThernal(3,2)+hw;
                    TagCornerThernal(3,1)+hw TagCornerThernal(3,2);
                    TagCornerThernal(3,1) TagCornerThernal(3,2);
                    TagCornerThernal(3,1) TagCornerThernal(3,2)+hw];

tform = fitgeotform2d(TagCornerThernal,CornerPointsNew,"projective"); % fit the perspective transformation matrix
ThermalCorrected = imwarp(img,tform,'OutputView',imref2d(size(img)));

figure
imshow(ThermalCorrected)

end