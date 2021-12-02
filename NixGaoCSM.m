function [hstar,H0]=NixGaoCSM(DataDir,ARAdir)
    arguments
        DataDir char
        ARAdir char
    end
    CurrentDir=pwd;
    cd(DataDir)
    files=dir('*.txt');
    nfiles=length(files);
    
    RawTime=cell(nfiles,1);
    RawLoad=cell(nfiles,1);
    RawDisp=cell(nfiles,1);
    RawHardness=cell(nfiles,1);
    RawStiff=cell(nfiles,1);
    RawContactDepth=cell(nfiles,1);
    RawDispAmp=cell(nfiles,1);
    RawLoadAmp=cell(nfiles,1);
    for FileNumber=1:nfiles
        currentfile=dlmread(files(FileNumber).name,'\t',3,0);
        ModLoc=size(currentfile,2)-10;
        RawTime{FileNumber}=currentfile(:,1);
        RawLoad{FileNumber}=currentfile(:,3); 
        RawDisp{FileNumber}=currentfile(:,2);
        RawHardness{FileNumber}=currentfile(:,ModLoc+2); 
        RawStiff{FileNumber}=currentfile(:,ModLoc+2+3);
        RawContactDepth{FileNumber}=currentfile(:,end);
        RawDispAmp{FileNumber}=currentfile(:,ModLoc-4);
        RawLoadAmp{FileNumber}=currentfile(:,ModLoc-2);
    end
    [~, ~, EndTimes, ~, ~]=ReadPRM(DataDir);
    %[ZeroDisp,ZeroLoad,~,ZeroHard]=ZeroHLIndentLoadDisp(RawDisp,RawLoad,RawTime,RawStiff,ARAdir);
    [ZeroDisp,~,~,ZeroHard]=ManualRezeroLD(RawDisp,RawLoad,RawStiff,RawDispAmp,RawLoadAmp,ARAdir);
    
    ZeroContactDepth=cell(nfiles,1);
    for FileNumber=1:nfiles
        dispDif=RawDisp{FileNumber}-ZeroDisp{FileNumber};
        ZeroContactDepth{FileNumber}=RawContactDepth{FileNumber}-dispDif;
    end
    CutHardness=CutAfter(ZeroHard,RawTime,EndTimes(end));
    CutContactDepth=CutAfter(ZeroContactDepth,RawTime,EndTimes(end));
    
    DispCut=120;
    CutHardness=CutBefore(CutHardness,CutContactDepth,DispCut);
    CutContactDepth=CutBefore(CutContactDepth,CutContactDepth,DispCut);
    
    
    H0=zeros(nfiles,1);
    hstar=zeros(nfiles,1);
    for FileNumber=1:nfiles
        Myhc=CutContactDepth{FileNumber};
        MyH=CutHardness{FileNumber};
        MyOneOverDisp=Myhc.^(-1);
        MyHSquared=MyH.^2;
        Myfit=polyfit(MyOneOverDisp,MyHSquared,1);
        MySlope=Myfit(1);
        MyInt=Myfit(2);
        MyH0Squared=MyInt;
        H0(FileNumber)=sqrt(MyH0Squared);
        hstar(FileNumber)=MySlope/MyH0Squared;
    end
    %{
    figure(3)
    plot(Myhc,MyH,'ko')
    xlabel('Contact depth (nm)')
    ylabel('Hardness (GPa)')

    figure(4)
    hold on
    plot(MyOneOverDisp,MyHSquared,'ko')
    plot(MyOneOverDisp,polyval(Myfit,MyOneOverDisp),'r')
    xlabel('1/h_c (nm^{-1})')
    ylabel('H^2 (GPa^2)')
    %}
    
    %Outlier detection and removal
    [Newhstar,removed]=rmoutliers(hstar);
    for i=length(hstar):-1:1
        if removed(i)==1
            H0(i)=[];
        end
    end
    clear hstar
    hstar=mean(Newhstar);
    H0=mean(H0);
    cd(CurrentDir)


end
    