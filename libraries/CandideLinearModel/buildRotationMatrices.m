function [ Rx, Ry, Rz ] = buildRotationMatrices( dims )

if (dims == 3)
    Rx = [0  0  0; 0  0 -1;  0  1  0];
    Ry = [0  0  1; 0  0  0; -1  0  0];
    Rz = [0 -1  0; 1  0  0;  0  0  0];
elseif (dims == 2)
    Rx = [0  -1;  1  0];
end
end