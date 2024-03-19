%%% Author: Cheng ZHANG
%%% Date: 3/01/2024

clear;clc;close all

cd = '.\Dataset for UAV thermography in building envelope inspection\Laboratory investigation\Grey-scale palette\Insulation failures\Temperature increasing';
RGBcd = [cd,'.\RGB\*.jpg'];

RGBdata = dir(RGBcd);                  %Get all images in the RGB folder

Thermalcd = [cd,'.\Thermal images\Rectified thermal image\*.jpg'];
Thermaldata = dir(Thermalcd);          %Get all images in the Thermal folder

M = length(RGBdata);                 %Number of images

for i =1:M
    RGB_name(i,:) = strcat(RGBcd(1:length(RGBcd)-6),'\',RGBdata(i,1).name);  %get the file path for each RGB image
    Thermal_name(i,:) = strcat(Thermalcd(1:length(Thermalcd)-6),'\',Thermaldata(i,1).name);  %get the file path for each Thermal image
end

ScaleThermal = zeros(M,1);
for i = 1:M
    RGB = imread(RGB_name(i,:));
    Thermal = imread(Thermal_name(i,:));

    %%%%%Select a function based on the facade to be processed
    % [ThermalCorrected,Scale] = ThermalImageCorrectionInsulation(RGB,Thermal); %Correct thermal images and output the results
    [ThermalCorrected,Scale] = ThermalImageCorrectionSurface(RGB,Thermal); %Correct thermal images and output the results
    
    imwrite(ThermalCorrected, [cd,'\Thermal images\Spatiaclly calibratied images\',Thermaldata(i,1).name], 'jpg');  %Save the corrected thermal images
    ScaleThermal(i,1) = Scale;  %Save the calculated scales
end 
