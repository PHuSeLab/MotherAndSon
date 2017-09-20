function [candidePts, map] =  mapCandidePts (fiducial, landmarkMode)
%% Definizione delle mappe di corrispondenza tra punti fiduciali e punti del modello CANDIDE-3

% First column : the tracked points (fiducial),
% Second column: corresponding CANDIDE-3 points

switch landmarkMode
    case {'OF','CK','AA','TC'}
        map=[31,6;
            34,7;
            52,8;
            58,9;
            9,11;
            18,16;
            20,17;
            22,18;
            37,21;
            40,24;
            32,27;
            3,29;
            1,30;
            6,31;
            %61,32;
            49,32;
            8,33;
            51,34;
            67,41;
            27,49;
            25,50;
            23,51;
            46,54;
            43,57;
            36,60;
            15,62;
            17,63;
            12,64;
            55,65;
            %65,65;
            10,66;
            53,67;
            50,80;
            54,81;
            62,82;
            64,83;
            68,84;
            66,85;
            60,86;
            56,87;
            63,88;
            61,89;
            65,90;
            29,95;
            38,98;
            45,99;
            42,100;
            47,101;
            39,106;
            44,107;
            41,108;
            48,109;
            33,112;
            35,113;
            % extra points
            69,22;
            70,23;
            71,55;
            72,56];
    case 'ZR'
        map=[27,49;
            29,50;
            31,51;
            16,16;
            17,17;
            20,18;
            15,21;
            73,20;
            10,24;
            72,25;
            26,54;
            75,53;
            21,57;
            74,58;
            70,93;
            71,94;
            50,32;
            33,34;
            32,8;
            39,67;
            41,65;
            44,87;
            69,42;
            48,86];
end

%% Import dei frames e dei punti fiduciali
nFrames = size(fiducial,3);

candidePts = zeros(length(map),2,nFrames);

for i=1:nFrames
    % add extra points
    fiducial(69,1,i) = (fiducial(38,1,i) + fiducial(39,1,i)) / 2;
    fiducial(69,2,i) = min([fiducial(38,2,i),fiducial(39,2,i)]);
    
    fiducial(70,1,i) = (fiducial(41,1,i) + fiducial(42,1,i)) / 2;
    fiducial(70,2,i) = max([fiducial(41,2,i), fiducial(42,2,i)]);
    
    fiducial(71,1,i) = (fiducial(44,1,i) + fiducial(45,1,i)) / 2;
    fiducial(71,2,i) = min([fiducial(44,2,i),fiducial(45,2,i)]);
    
    fiducial(72,1,i) = (fiducial(47,1,i) + fiducial(48,1,i)) / 2;
    fiducial(72,2,i) = max([fiducial(47,2,i),fiducial(48,2,i)]);
    
    candidePts(:,1,i) = fiducial(map(:,1),1,i);
    candidePts(:,2,i) = fiducial(map(:,1),2,i);
end