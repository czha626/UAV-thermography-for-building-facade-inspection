%%% Author: Cheng ZHANG
%%% Date: 01/03/2024

%% Load image and define the ROI 
clc;clear;close all

% load image
Img = imread('.\DJI_0131.jpg');

figure;
imshow(Img);

P = ginput();                      % click two point in the image: first upper left corner then lower right corner
hold on
scatter(P(1,1),P(1,2),'gs','linewidth',2);hold on
scatter(P(2,1),P(2,2),'gs','linewidth',2);hold on

X = P(1,1); Y = P(1,2);         % Draw ROI
W = floor(abs(P(1,1)-P(2,1)));  % width of the rectangle ROI
H = floor(abs(P(1,2)-P(2,2)));  % height  of the rectangle ROI
ROI = images.roi.Rectangle('position',[X,Y,W,H],'StripeColor','r');

mask = createMask(ROI,Img);
mask = 1-mask;
imshow(mask)

Img_ROI = imoverlay(Img,mask,'k');
imshow(Img_ROI)
%% Kmeans clustering to classify image ROI into clusters
nColors = 3; % set the numbers of clustering
% repeat the clustering 3 times to avoid local minima
pixel_labels = imsegkmeans(Img_ROI,nColors,'NumAttempts',3);

imshow(pixel_labels,[])
title('Image Labeled by Cluster Index');

PixelNum = [];
for i = 1:nColors
    mask_cluster = pixel_labels==i;
    cluster = Img_ROI .* uint8(mask_cluster);
    cluster_gray = rgb2gray(cluster);
    PixelNum(i,1) = nnz(cluster_gray);
    figure(i)
    imshow(cluster)
    title(['Cluster',num2str(i)])
    %imwrite(cluster, ['Cluster',num2str(i),'.jpg'], 'jpg');
end

%% Select the index for the cluster represent thermal damage and export the result
prompt = "What is the cluster number of thermal damage? ";
index = input(prompt);
mask_thermal = pixel_labels==index;
cluster_thermal = Img_ROI .* uint8(mask_thermal);
imwrite(cluster_thermal, '1.jpg', 'jpg');
