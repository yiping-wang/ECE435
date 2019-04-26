for i = 0:15
    if i < 10
        append = '0';
    else
        append = '';
    end
    nameIm = strcat('dataset/real/EDF0', append, num2str(i), '.png');
    nameGt = strcat('dataset/real/EDF0', append, num2str(i), '_GT.png');
    Im = imread(nameIm);
    ImGt = imread(nameGt);
    [JI, DC] = evaluateNucleiSeg(Im, ImGt, 0);
    
    disp(i);
    disp(JI);
    disp(DC);
end