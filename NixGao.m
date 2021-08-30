function [hstar,H0]=NixGao(DataDir,row)
    arguments
        DataDir char
        row double = 3
    end
    CurrentDir=pwd;
    cd(DataDir)
    files=dir('*.txt');
    FileNumber=1;

    %Normally use row 3 to start. Here, use 7 because others are at ~1 nm
    currentfile=dlmread(files(FileNumber).name,'\t',row,1);


    Myhc=currentfile(:,1);
    MyE=currentfile(:,7);
    MyH=currentfile(:,8);



    MyOneOverDisp=Myhc.^(-1);
    MyHSquared=MyH.^2;
    Myfit=polyfit(MyOneOverDisp,MyHSquared,1);
    MySlope=Myfit(1);
    MyInt=Myfit(2);
    MyH0Squared=MyInt;
    H0=sqrt(MyH0Squared);
    hstar=MySlope/MyH0Squared;

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

    cd(CurrentDir)


end
    