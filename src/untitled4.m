clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 22;

% Parameters
NUMUNE_CAPI = 30;
FOTOGRAF_CEKME_ARALIGI = 1;
Gamma = 0.98;
Phi = 200;
Epsilon = -0.1;
k = 1.6;
Sigma = 0.8;

cropXpercent1=0.525;
cropXpercent2=0.625;

cropRefXpercent1=0.55;
cropRefXpercent2=0.575;
cropRefYpercent1=0.45;
cropRefYpercent2=0.55;

window_size = 31; 
imgFolder = '1S 950H14 120MIN';
outputFolder = "output2\" + imgFolder+"_output";
binaryFolder = "binary2\" + imgFolder+"_binary";
refFolder = "ref\" + imgFolder+"_ref";
imgFolder = "img\" + imgFolder;
%--------------------------------------------------------------------------------------------------------
whichPhotosLeft = [12,13];
fixDistanceLeft = [1,2];
%whichPhotos hangi fotoğraflardan kırpılacağını
%fixDistance ise kaç cm kırpılacağını içerir
whichPhotosRight = [12,13];
fixDistanceRight = [2,1];
%--------------------------------------------------------------------------------------------------------


folder = pwd;
parentDirectory = fileparts(folder); 
fullFileName = fullfile(parentDirectory, imgFolder);
imgList = dir(fullFileName);
imgList([imgList.isdir]) = [];
flag = true;
firstDistance = 0;
numImg = length(imgList);
distances = zeros(numImg,1);

for l = 1 : numImg
    imgFile = fullfile(fullFileName, imgList(l).name);
        % Check if file exists.
    if ~exist(imgFile, 'file')
	    fullFileNameOnSearchPath = imgList(l).name; 
	    if ~exist(fullFileNameOnSearchPath, 'file')
		    errorMessage = sprintf('Error: %s does not exist in the search path folders.', imgFile);
		    uiwait(warndlg(errorMessage));
		    return;
	    end
    end
    orjinalImage = imread(imgFile);
    grayImage = imread(imgFile);
    binaryImage = imread(imgFile);
    [rows, columns, numberOfColorChannels] = size(grayImage);

    if numberOfColorChannels > 1
	    % It's not really gray scale like we expected - it's color.
	    % Use weighted sum of ALL channels to create a gray scale image.
	    grayImage = rgb2gray(grayImage);
        orjinalImage = rgb2gray(orjinalImage);
        binaryImage = rgb2gray(binaryImage);
	    % ALTERNATE METHOD: Convert it to gray scale by taking only the green channel,
	    % which in a typical snapshot will be the least noisy channel.
	    % grayImage = grayImage(:, :, 2); % Take green channel.
    end
    % Display the image.
    
    rawXsize = size(grayImage,1);

    grayImage = grayImage(round(rawXsize*cropXpercent1):round(rawXsize*cropXpercent2),:);
    rawRefXsize = size(grayImage,1);
    rawRefYsize = size(grayImage,2);
    
    

    %--------------------------------------------------------------------------------------------------------




    x = size(grayImage,1);
    y = size(grayImage,2);

    filter_type=fspecial('average', window_size); 
    grayImage = imfilter(grayImage,filter_type, 'replicate'); %%%  I = image

   
    refImage = grayImage(round(rawRefXsize*cropRefXpercent1):round(rawRefXsize*cropRefXpercent2),round(rawRefYsize*cropRefYpercent1):round(rawRefYsize*cropRefYpercent2));
    meanValue = graythresh(refImage)*256;
    std = std2(refImage);

    % thresholding
    for i=1:x
        for j=1:y
            if(grayImage(i, j)<= (meanValue +3*std))
                grayImage(i, j) = 256;
                %binaryImage(i,j) = 256;
                %binaryImage(i+round(rawXsize*cropXpercent1),j) = 256;
            else
                grayImage(i, j) = 0;
                %binaryImage(i,j) = 0;
                %binaryImage(i+round(rawXsize*cropXpercent1),j) = 0;
            end

        end
    end

    a = size(binaryImage,1);
    b = size(binaryImage,2);
    for i=1:a
        for j=1:b
            if(binaryImage(i, j)<= (meanValue +3*std))
                %grayImage(i, j) = 256;
                %binaryImage(i,j) = 256;
                binaryImage(i,j) = 256;
            else
                %grayImage(i, j) = 0;
                %binaryImage(i,j) = 0;
                binaryImage(i,j) = 0;
            end

        end
    end

    boundaries = bwboundaries(grayImage);

    minX=0;
    maxX=0;

    thisBoundary = boundaries{1};
    y = thisBoundary(:, 1);
    y=y+round(rawXsize*cropXpercent1);
    minY=min(y);
    maxY=max(y);
    x = thisBoundary(:, 2);

    distance = zeros(length(y),1);
    for i = 1 : length(y)
        for j = 1 :length(y)
            if(y(i) == y(j) && (distance(i)<(x(j) - x(i))))
                distance(i) = x(j) - x(i);
            end
        end
    end
    [maxDistance,indexX] = max(distance);
    if(flag)
        flag = false;
        firstDistance = maxDistance;
        distances(l) = NUMUNE_CAPI;
    else
        distances(l) = maxDistance*NUMUNE_CAPI/firstDistance;
        if(ismember(l,whichPhotosLeft))
            distances(l) = distances(l) - fixDistanceLeft(find(whichPhotosLeft==l));
            maxDistance = maxDistance -fixDistanceLeft(find(whichPhotosLeft==l))*firstDistance/NUMUNE_CAPI;
            x(indexX) = x(indexX) + fixDistanceLeft(find(whichPhotosLeft==l))*firstDistance/NUMUNE_CAPI;
        end

        if(ismember(l,whichPhotosRight))
            distances(l) = distances(l) - fixDistanceRight(find(whichPhotosRight==l));
            maxDistance = maxDistance -fixDistanceRight(find(whichPhotosRight==l))*firstDistance/NUMUNE_CAPI;
        end
    end


    fullFolderName = fullfile(parentDirectory, refFolder);
    fileName = fullfile(fullFolderName, l + ".jpeg");
    if ~exist(fullFolderName, 'dir')
        mkdir(fullFolderName)
    end
    imwrite(refImage,fileName);


    fullFolderName = fullfile(parentDirectory, outputFolder);
    fileName = fullfile(fullFolderName, l + ".jpeg");
    if ~exist(fullFolderName, 'dir')
        mkdir(fullFolderName)
    end
    imageForWrite = insertShape(orjinalImage,'line',[x(indexX) y(indexX);x(indexX)+maxDistance y(indexX)],'Color','red','LineWidth',6);
    txt = string(distances(l));
    imageForWrite = insertText(imageForWrite,[round((x(indexX) +x(indexX)+maxDistance)/2 - 50) y(indexX)-90], txt, "BoxOpacity",0,FontSize=50,TextColor="red");
    imwrite(imageForWrite,fileName);


    fullFolderName = fullfile(parentDirectory, binaryFolder);
    fileName = fullfile(fullFolderName, l + ".jpeg");
    if ~exist(fullFolderName, 'dir')
        mkdir(fullFolderName)
    end

    imageForBinaryWrite = insertShape(binaryImage,'line',[x(indexX) y(indexX);x(indexX)+maxDistance y(indexX)],'Color','red','LineWidth',6);
    txt = string(distances(l));
    imageForBinaryWrite = insertText(imageForBinaryWrite,[round((x(indexX) +x(indexX)+maxDistance)/2 - 50) y(indexX)-90], txt, "BoxOpacity",0,FontSize=50,TextColor="red");
    imwrite(imageForBinaryWrite,fileName);
end
x_range = linspace(0,numImg*FOTOGRAF_CEKME_ARALIGI,numImg+1);
x_range = x_range(1:end-1);
x_range = x_range';
if ~exist(fullfile(parentDirectory, outputFolder), 'dir')
        mkdir(fullfile(parentDirectory, imgFolder+"_output"))
end
T = table(x_range,distances);
writetable(T,fullfile(fullfile(parentDirectory, outputFolder), "distances.csv"),Delimiter=",");
plot(x_range,distances);
xticks(0:FOTOGRAF_CEKME_ARALIGI:numImg*FOTOGRAF_CEKME_ARALIGI);