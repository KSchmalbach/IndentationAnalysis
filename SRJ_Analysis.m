function [VStar,SRSens,Table]=SRJ_Analysis(PRMDir,AnMode,Hardness,StorMod,Time,Load,Disp,Options)
    arguments
        PRMDir char %Directory of .prm file
        AnMode char
        %AnMode chooses the method to analyze strain rate sensitivity
        %There are two modes, 'regression' and 'average'
        %'regression' extrapolates hardness back to the start of the jump
        %to get the hardness of that strain rate
        %'average' takes the average of the end of the segment to get the
        %hardness of that strain rate
        Hardness cell %Hardness data
        StorMod cell %Modulus data
        Time cell %Time data
        Load cell %Load data
        Disp cell %Displacement data
        
        Options.DistIn double = 0 %Percentages of data to ignore transients (arbitrary, change to fit)
        %DistIn is a vector with length = number of jumps = num SR-1
        %If DistIn not supplied, but AnMode is 'regression', will open
        %dialogue to systematically show data
        Options.Temp double = 300 %Test temperature, K
        Options.SegmentPlot logical = true %Plotting option to show all SR segments
        Options.ReprodPlot logical = false %Plotting option to show all tests H vs d
        Options.Binning logical = false %Option to bin the data
        Options.ExamplePlot double = 0 %Test number to plot depth dependence
    end


Table=cell(4,1);

%Constants
k=1.38e-23; %J/K
T=Options.Temp; %K

set(0,'defaultAxesFontSize',18)

%Various plotting and analysis options
SegmentPlot=Options.SegmentPlot;
ReprodPlot=Options.ReprodPlot;
Binning=Options.Binning;
DistIn=Options.DistIn;

[SRNum, Strains, EndTimes, PPSeg, ~]=ReadPRM(PRMDir);

nfiles=length(Disp);

%Plot all tests
if ReprodPlot==true
    maxLength=max(cellfun(@(x) length(x),Hardness,'UniformOutput',true));
    avgLength=ceil(mean(cellfun(@(x) length(x),Hardness,'UniformOutput',true)));
    TempHard=zeros(maxLength,nfiles);
    TempDisp=zeros(maxLength,nfiles);
    for FileNumber=1:nfiles
        TempLength=length(Hardness{FileNumber});
        TempHard(1:TempLength,FileNumber)=Hardness{FileNumber};
        TempDisp(1:TempLength,FileNumber)=Disp{FileNumber};
        if TempLength ~= maxLength
            TempHard(TempLength+1:end,FileNumber)=NaN;
            TempDisp(TempLength+1:end,FileNumber)=NaN;
        end
    end
    TempHard(TempHard==0)=NaN;
    TempDisp(TempDisp==0)=NaN;
    ReprodAvgH=mean(TempHard,2,'omitnan');
    ReprodAvgDisp=mean(TempDisp,2,'omitnan');
    ReprodStdH=std(TempHard,0,2,'omitnan');
    %Eliminates some weird things that occur when things are different
    %length
    ReprodAvgH(avgLength:end)=[];
    ReprodAvgDisp(avgLength:end)=[];
    ReprodStdH(avgLength:end)=[];
    opac=0.9;
    figure(1984)
    box on
    hold on
    fill([ReprodAvgDisp;flipud(ReprodAvgDisp)],[ReprodAvgH-ReprodStdH;flipud(ReprodAvgH+ReprodStdH)],[0.9 0.9 0.9]*opac,'linestyle','none');
    plot(ReprodAvgDisp,ReprodAvgH,'k')
    xlabel('Displacement (nm)')
    ylabel('Hardness (GPa)')
    hold off
end
clear TempHard TempDisp


%Find where the jumps occur and save indices to Changeover
Changeover=cell(nfiles,1);
for FileNumber=1:nfiles
    TimePerPoint=(Time{FileNumber}(end)-Time{FileNumber}(1))/length(Time{FileNumber});
    StartTime=Time{FileNumber}(1);
    ExpectPoint=round((EndTimes(1)-StartTime)/TimePerPoint);
    %Bound=round(EndTimes(1)/2);
    Bound=round(1.5/TimePerPoint); %Look in +/- 1.5 sec from expected point
    for SegNum=1:SRNum-1
        for Point=max(2,ExpectPoint-Bound):ExpectPoint+Bound
             if Time{FileNumber}(Point-1)<EndTimes(SegNum) & Time{FileNumber}(Point)>=EndTimes(SegNum)
                Changeover{FileNumber}(SegNum)=Point;
                break
             end
        end
        ExpectPoint=round((EndTimes(SegNum+1)-EndTimes(SegNum))/TimePerPoint+Changeover{FileNumber}(SegNum));
    end
    Changeover{FileNumber}(SRNum)=length(Disp{FileNumber});
end
  
%Make new data string that holds the strain rate
for FileNumber=1:nfiles
    AvgSR{FileNumber}(1:Changeover{FileNumber}(1)-1)=Strains(1);
    for SegNum=1:SRNum-1
        AvgSR{FileNumber}(Changeover{FileNumber}(SegNum):Changeover{FileNumber}(SegNum+1)-1)=Strains(SegNum+1);
    end
    AvgSR{FileNumber}(Changeover{FileNumber}(end):length(Time{FileNumber}))=Strains(end);
end
SeparatedData=cell(1,6,nfiles,SRNum);

%Separate data into multi-dimensional array by strain rate segment
for FileNumber=1:nfiles
    SegmentNumber=1;
    %Make initial array
    SeparatedData{1,1,FileNumber,SegmentNumber}=Disp{FileNumber}(1:Changeover{FileNumber}(1)-1);
    SeparatedData{1,2,FileNumber,SegmentNumber}=Hardness{FileNumber}(1:Changeover{FileNumber}(1)-1);
    SeparatedData{1,3,FileNumber,SegmentNumber}=AvgSR{FileNumber}(1:Changeover{FileNumber}(1)-1);
    SeparatedData{1,4,FileNumber,SegmentNumber}=Time{FileNumber}(1:Changeover{FileNumber}(1)-1);
    SeparatedData{1,5,FileNumber,SegmentNumber}=Load{FileNumber}(1:Changeover{FileNumber}(1)-1);
    SeparatedData{1,6,FileNumber,SegmentNumber}=StorMod{FileNumber}(1:Changeover{FileNumber}(1)-1);
    for SegmentNumber=2:SRNum-1
        SeparatedData{1,1,FileNumber,SegmentNumber}=Disp{FileNumber}(Changeover{FileNumber}(SegmentNumber-1):Changeover{FileNumber}(SegmentNumber)-1);
        SeparatedData{1,2,FileNumber,SegmentNumber}=Hardness{FileNumber}(Changeover{FileNumber}(SegmentNumber-1):Changeover{FileNumber}(SegmentNumber)-1);
        SeparatedData{1,3,FileNumber,SegmentNumber}=AvgSR{FileNumber}(Changeover{FileNumber}(SegmentNumber-1):Changeover{FileNumber}(SegmentNumber)-1);
        SeparatedData{1,4,FileNumber,SegmentNumber}=Time{FileNumber}(Changeover{FileNumber}(SegmentNumber-1):Changeover{FileNumber}(SegmentNumber)-1);
        SeparatedData{1,5,FileNumber,SegmentNumber}=Load{FileNumber}(Changeover{FileNumber}(SegmentNumber-1):Changeover{FileNumber}(SegmentNumber)-1);
        SeparatedData{1,6,FileNumber,SegmentNumber}=StorMod{FileNumber}(Changeover{FileNumber}(SegmentNumber-1):Changeover{FileNumber}(SegmentNumber)-1);
    end
    SegmentNumber=SRNum;
    SeparatedData{1,1,FileNumber,SegmentNumber}=Disp{FileNumber}(Changeover{FileNumber}(end-1):end);
    SeparatedData{1,2,FileNumber,SegmentNumber}=Hardness{FileNumber}(Changeover{FileNumber}(end-1):end);
    SeparatedData{1,3,FileNumber,SegmentNumber}=AvgSR{FileNumber}(Changeover{FileNumber}(end-1):end);
    SeparatedData{1,4,FileNumber,SegmentNumber}=Time{FileNumber}(Changeover{FileNumber}(end-1):end);
    SeparatedData{1,5,FileNumber,SegmentNumber}=Load{FileNumber}(Changeover{FileNumber}(end-1):end);
    SeparatedData{1,6,FileNumber,SegmentNumber}=StorMod{FileNumber}(Changeover{FileNumber}(end-1):end);
end

%}
%Average each segment into above number of bins
if Binning==true
    %Number of bins to separate data into
    nBins=60;
    for FileNumber=1:nfiles
        for SegmentNumber=1:SRNum
            clear AvgDisp AvgH AvgTime AvgSR AvgLoad SepDisp SepH SepLoad SepSR SepTime
            nData=length(SeparatedData{1,1,FileNumber,SegmentNumber});
            nPerBin=int32(nData/nBins);
            SepDisp=SeparatedData{1,1,FileNumber,SegmentNumber};
            SepH=SeparatedData{1,2,FileNumber,SegmentNumber};
            SepSR=SeparatedData{1,3,FileNumber,SegmentNumber};
            SepTime=SeparatedData{1,4,FileNumber,SegmentNumber};
            SepLoad=SeparatedData{1,5,FileNumber,SegmentNumber};
            SepMod=SeparatedData{1,6,FileNumber,SegmentNumber};
            for Point=1:nBins
                %Num of points may not be integer multiple of nBins
                if nPerBin*Point>length(SepDisp)
                    break
                else
                    AvgDisp(Point,1)=mean(SepDisp(nPerBin*(Point-1)+1:nPerBin*Point));
                    AvgH(Point,1)=mean(SepH(nPerBin*(Point-1)+1:nPerBin*Point));
                    AvgTime(Point,1)=mean(SepTime(nPerBin*(Point-1)+1:nPerBin*Point));
                    AvgSR(Point,1)=mean(SepSR(nPerBin*(Point-1)+1:nPerBin*Point));
                    AvgLoad(Point,1)=mean(SepLoad(nPerBin*(Point-1)+1:nPerBin*Point));
                    AvgMod(Point,1)=mean(SepMod(nPerBin*(Point-1)+1:nPerBin*Point));
                end
            end
            clear SeparatedData{1,:,FileNumber,SegmentNumber}
            SeparatedData{1,1,FileNumber,SegmentNumber}=AvgDisp;
            SeparatedData{1,2,FileNumber,SegmentNumber}=AvgH;
            SeparatedData{1,3,FileNumber,SegmentNumber}=AvgSR;
            SeparatedData{1,4,FileNumber,SegmentNumber}=AvgTime;
            SeparatedData{1,5,FileNumber,SegmentNumber}=AvgLoad;
            SeparatedData{1,6,FileNumber,SegmentNumber}=AvgMod;
        end
    end
    clear AvgDisp AvgH AvgTime AvgSR AvgLoad SepDisp SepH SepLoad SepSR SepTime nPoints nData Point nPerBin
end

%Calculate actual SR from 1/2 Pdot/P
for FileNumber=1:nfiles
    for SegmentNumber=1:SRNum
        SRCalc=zeros(length(SeparatedData{1,1,FileNumber,SegmentNumber}),1);
        for Point=1:length(SeparatedData{1,1,FileNumber,SegmentNumber})-1
            Pdot(Point,1)=(SeparatedData{1,5,FileNumber,SegmentNumber}(Point+1)-SeparatedData{1,5,FileNumber,SegmentNumber}(Point))/(SeparatedData{1,4,FileNumber,SegmentNumber}(Point+1)-SeparatedData{1,4,FileNumber,SegmentNumber}(Point));
            SRCalc(Point,1)=1/2*Pdot(Point,1)/SeparatedData{1,5,FileNumber,SegmentNumber}(Point);
        end
        SeparatedData{1,7,FileNumber,SegmentNumber}=SRCalc;
        clear SRCalc Pdot
    end
end
clear Point

%Check strain rates
if Options.ExamplePlot ~= 0 && Options.ExamplePlot <= nfiles
    TEST=Options.ExamplePlot;
    figure(1111)
    box on
    yyaxis left
    for SegmentNumber=1:SRNum
        hold on
        plot(SeparatedData{1,1,TEST,SegmentNumber}(:),SeparatedData{1,2,TEST,SegmentNumber}(:),'k.')
    end
    ylabel('Hardness (GPa)')
    ax1=gca;
    ax1.YColor='k';
    
    if max(SeparatedData{1,2,TEST,SegmentNumber}(:))<1
        UpperBound=round(2*max(SeparatedData{1,2,TEST,SegmentNumber}(:)),1);
    else
        UpperBound=round(2*max(SeparatedData{1,2,TEST,SegmentNumber}(:)));
    end
    ylim([0 UpperBound])
    yyaxis right
    hold on
    for SegmentNumber=1:SRNum
        plot(SeparatedData{1,1,TEST,SegmentNumber}(:),SeparatedData{1,3,TEST,SegmentNumber}(:),'r.')
    end
    ylabel('Strain rate (s^{-1})')
    ax2=gca;
    ax2.YColor='r';
    set(gca,'yscale','log')
    ylim([1e-4 10])
    xlabel('Displacement (nm)')
end

dlnEdH=zeros(SRNum-1,nfiles);
SRSens=zeros(SRNum-1,nfiles);
Depth=zeros(SRNum-1,nfiles);
VStar=zeros(SRNum-1,nfiles);
ExpMod=zeros(SRNum,nfiles);
HardStart=zeros(SRNum,nfiles);
HardEnd=zeros(SRNum,nfiles);


if strcmp(AnMode,'regression')
    %If DistIn values are not provided, open up interactive selection
    if DistIn==0
        for SegmentNumber=1:SRNum
            for FileNumber=1:nfiles
                TempH{FileNumber}=SeparatedData{1,2,FileNumber,SegmentNumber};
                TempDisp{FileNumber}=SeparatedData{1,1,FileNumber,SegmentNumber};
            end
            DistIn(SegmentNumber)=DistInFigure(TempDisp,TempH,SegmentNumber);
            SR(SegmentNumber)=SeparatedData{1,3,1,SegmentNumber}(1);
            SegmentPlot=false;
            Table{4}=DistIn;
        end
    end

    %Reduce to be regression line data (H, disp) start and end
    for FileNumber=1:nfiles
        for SegmentNumber=1:SRNum
            %Load in one strain rate at a time
            Disp=rmmissing(SeparatedData{1,1,FileNumber,SegmentNumber});
            H=rmmissing(SeparatedData{1,2,FileNumber,SegmentNumber});
            Mod=rmmissing(SeparatedData{1,6,FileNumber,SegmentNumber});
            nPoints=length(Disp); %Number of data points in segment
            In=round(DistIn(SegmentNumber)*nPoints); %Index to start regression
            Reg=polyfit(Disp(In:end),H(In:end),1); %Perform linear regression
            RegLine=polyval(Reg,Disp);
            if SegmentPlot==true
                figure(SegmentNumber)
                hold on
                d=plot(Disp,H,'ro');
                r=plot(Disp,RegLine,'b');
                hold off
                xlabel('Displacement (nm)')
                ylabel('Hardness (GPa)')
            end
            ExpMod(SegmentNumber,FileNumber)=mean(Mod(In:end));
            HardStart(SegmentNumber,FileNumber)=RegLine(1);
            HardEnd(SegmentNumber,FileNumber)=RegLine(end);
            ExpHard=HardEnd;
            if SegmentNumber>1
                Depth(SegmentNumber-1,FileNumber)=Disp(1);
            end
        end
    end
    for FileNumber=1:nfiles
        for SegmentNumber=2:SRNum
            dlogSR=log(SR(SegmentNumber))-log(SR(SegmentNumber-1));
            dH=HardStart(SegmentNumber,FileNumber)-HardEnd(SegmentNumber-1,FileNumber);
            dlogH=log(HardStart(SegmentNumber,FileNumber))-log(HardEnd(SegmentNumber-1,FileNumber));
            dlnEdH(SegmentNumber-1,FileNumber)=dlogSR/dH;
            SRSens(SegmentNumber-1,FileNumber)=dlogH/dlogSR;
            
            VStar(SegmentNumber-1,FileNumber)=3.*sqrt(3).*k.*T.*dlnEdH(SegmentNumber-1,FileNumber)./1e9; %m^3
        end
    end
    clear In DistIn Reg RegLine nPoints H SR Disp
else %If strcmp(AnMode,'average')
    %By using average of last few (1%) points
    for FileNumber=1:nfiles
        for SegmentNumber=1:SRNum
            %Load in one strain rate at a time
            PointsToAvg=ceil(0.01*length(SeparatedData{1,2,FileNumber,SegmentNumber}));
            H=SeparatedData{1,2,FileNumber,SegmentNumber};
            SR=SeparatedData{1,3,FileNumber,SegmentNumber}(1);
            AveragedHardness=mean(SeparatedData{1,2,FileNumber,SegmentNumber}(end-PointsToAvg:end));
            AveragedModulus=mean(SeparatedData{1,6,FileNumber,SegmentNumber}(end-PointsToAvg:end));
            ExpHard(SegmentNumber,FileNumber)=AveragedHardness;
            ExpMod(SegmentNumber,FileNumber)=AveragedModulus;
        end
        for SegmentNumber=2:SRNum
            dlnEdH(SegmentNumber-1,FileNumber)=(log(HardAndSR(SegmentNumber+SRNum*(FileNumber-1),2))-log(HardAndSR(SegmentNumber-1+SRNum*(FileNumber-1),2)))/(HardAndSR(SegmentNumber+SRNum*(FileNumber-1),1)-HardAndSR(SegmentNumber-1+SRNum*(FileNumber-1),1));
            SRSens(SegmentNumber-1,FileNumber)=(log(HardAndSR(SegmentNumber+SRNum*(FileNumber-1),1))-log(HardAndSR(SegmentNumber-1+SRNum*(FileNumber-1),1)))/(log(HardAndSR(SegmentNumber+SRNum*(FileNumber-1),2))-log(HardAndSR(SegmentNumber-1+SRNum*(FileNumber-1),2)));
            Depth(SegmentNumber-1,FileNumber)=SeparatedData{1,1,FileNumber,SegmentNumber}(1);
            VStar(SegmentNumber-1,FileNumber)=3.*sqrt(3).*k.*T.*dlnEdH(SegmentNumber-1,FileNumber)./1e9; %m^3
        end
    end
end

Table{1}=ExpHard;
Table{2}=ExpMod;
Table{3}=Strains;
Table{5}=Depth;
end