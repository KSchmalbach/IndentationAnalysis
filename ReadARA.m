function Coeffs=ReadARA(ARAdir)
    OriginalDirectory=pwd;
    cd(ARAdir)
    AFfile=dir('*.ara');
    AFfile=fopen(AFfile(1).name);
    AFfile=fscanf(AFfile,'%c');
    Split=strsplit(AFfile,'\n');
    Coeffs=[str2num(Split{3}) str2num(Split{5}) str2num(Split{7}) str2num(Split{9}) str2num(Split{11}) str2num(Split{13})];
    cd(OriginalDirectory)
end