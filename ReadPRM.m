function [SRNum, Strains, EndTimes, PPSeg, Freq]=ReadPRM(PRMdir)
    arguments
        PRMdir char
    end
    currentdir=pwd;
    cd(PRMdir)
    prm=dir('*.prm');
    params=dlmread(prm.name,'\t',0,1);

    %Separate PRM file into individual parameters
    SRNum=params(1);
    Freq=params(2); %Not needed
    %Amp=params(3); %Not needed
    Strains=params(4:4+SRNum-1);
    %EndLoads=params(4+SRNum:4+2*SRNum-1); %Not needed
    EndTimes=params(4+2*SRNum:4+3*SRNum-1);
    PPSeg=params(4+3*SRNum);
    cd(currentdir)
end