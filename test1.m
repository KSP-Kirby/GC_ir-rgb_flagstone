load('flow_rect.mat')
imageSet = 1;
vl = -uv_vl{imageSet}(:,:,1);
ir = -uv_ir{imageSet}(:,:,1);

[rowsL, colsL, p] = size(ir);
[rowsR, colsR, p] = size(vl);

pixelDimR = .006;
pixelDimL = .0048;
f_l = 3.9676;        % left camera is ir
f_r = 7.8545;         % right camera is RGB
b =  3*25.4;         % stereo baseline
%b = 65;
d =  128.4867;         % dual focal length baseline
d =  148.2127;         % dual focal length baseline
d = 166;

rightPixel = [-143, -47, 39, 119, 208];
leftPixel = [-29, 44, 98, 143, 184];

rightRow = 240;
leftRow = round((rightRow - rowsR/2) + rowsL/2);
leftRow = 496;

figure
pixelAxisR = (1:1:640)-320;
pixelAxisL = (1:1:1280)-640;
plot(pixelAxisR, vl(rightRow,:))
hold all
plot(pixelAxisL, ir(leftRow,:))



% Figure
% plot(vl(rightRow,:))
% hold all
% plot(ir(leftRow,:))

for i = 1:length(rightPixel)
    ZestLeft(i) = 20*f_l/(ir(leftRow,leftPixel(i)+640)*pixelDimL);
    ZestRight(i) = 20*f_r/(vl(rightRow,rightPixel(i)+320)*pixelDimR);
    D(i) = ZestLeft(i) - ZestRight(i);
    m1(i) = vl(rightRow,rightPixel(i)+320)/(ir(leftRow,leftPixel(i)+640));
    m2(i) = m1(i)*ZestLeft(i)/ZestRight(i)*(pixelDimR/pixelDimL);
    plot(rightPixel(i), vl(rightRow,rightPixel(i)+320), '*r')
    plot(leftPixel(i), ir(leftRow,leftPixel(i)+640), '*r')
end

Dmean = mean(D);
d =  Dmean;
d = D(3);

minError = ones(1,8)*inf;
minErrorFound = 0;
index = 1;
for rightPixel = [-143, -47, 39, 119, 208]
    plot(rightPixel, vl(rightRow, rightPixel+320), '*r')
    for Z = 600:1500
        m = (pixelDimL/pixelDimR)*(f_r/f_l)*(Z+d)/(Z);
        leftRow = round((rightRow - rowsR/2)*m + rowsL/2)-16;
        x_r = (rightPixel)*pixelDimR;
        
        X_r = Z*x_r/f_r;
        X_l = X_r+b;
        x_l = f_l*X_l/(Z+d);
        
        x_l1 = (x_r*Z*f_l+b*f_r*f_l)/(f_r*Z+f_r*d);
        leftPixel = x_l/pixelDimL; 
        plot(round(leftPixel), vl(rightRow,rightPixel+320)/m, '*r')
        error = abs(vl(rightRow,rightPixel+320)/m - ir(round(leftRow),round(leftPixel)+640));
        if error < minError(index)
            minError(index) = error;
            LeftRowOut(index) = leftRow;
            leftPixelOut(index) = leftPixel;
            Zout(index) = Z;
            mout(index) = m;
        end
    end
    index = index+1;
end
