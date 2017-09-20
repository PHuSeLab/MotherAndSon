close all;
load('candide3.dat');
load('triangles.dat');


type = 'KN'; % 'CK', 'KN', 'OF'

knimg = '/media/vcuculo/Data/Datasets/AMHUSE/sample_data/10/1/002246.jpeg';
ckimg = '/media/vcuculo/Data/Datasets/Cohn Kanade/CK+/S022/001S/S022_001_00000001.png';

knpts_file = '/media/vcuculo/Data/Datasets/AMHUSE/sample_data/10/1/points/rgb_002246.dat';
ckpts_file = '/media/vcuculo/Data/Datasets/Cohn Kanade/Landmarks/S022/001S/S022_001_00000001_landmarks.txt';
ofpts_file = 'Data/landmarks/son_OF.txt';



switch type
    case 'KN'
        
        meaning_pts = [0,210,469,241,1104,843,1117,731,1090,346,140,222,...
                       803,758,849,91,687,19,1072,10,8,18,14,156,783,24,...
                       151,772,28,412,933,458,674,4,1307,1327];

        fileID = fopen(knpts_file);
        data = fread(fileID, 'float');
        data = reshape(data, 2, [])';
        
        %meaning_pts = 1:length(data);
        meaning_pts = meaning_pts + 1;
                
        
        figure;
        hold on;
        imshow(knimg);
        for l = 1:length(meaning_pts)
            hold on;
            plot(data(meaning_pts(l),1)+2,data(meaning_pts(l),2)+5, 'k.', 'Markersize', 15);%, 'markersize', 20);
            text(data(meaning_pts(l),1)+2,data(meaning_pts(l),2)+5, num2str(meaning_pts(l)));
        end

        title('kinect');
        hold off;
        
        
    case 'CK'
        ckpts = load(ckpts_file);
        figure;
        hold on;
        imshow(ckimg);
        for l = 1:length(ckpts)
            hold on;
            plot(ckpts(l,1),ckpts(l,2), 'b*');
            text(ckpts(l,1),ckpts(l,2), num2str(l), 'Color', [1, 1, 1]);
        end

        title('CK');
        hold off;
        axis ij;
        
    case 'OF'
        ofpts = load(ofpts_file);
        figure('units','normalized','outerposition',[0 .15 .5 1]);
        hold on;
        for l = 1:length(ofpts)
            plot(ofpts(l,1),ofpts(l,2), 'k.','markersize',20);
            text(ofpts(l,1)+2,ofpts(l,2)-2, num2str(l));
        end
        hold off;
        axis ij;
        axis normal;
        
end

figure;
hold on;
triplot(triangles+1,candide3(:,1), candide3(:,2));
for i=1:113
text(candide3(i,1), candide3(i,2), candide3(i,3),num2str(i));
pause;
end
title('Candide');
hold off;
