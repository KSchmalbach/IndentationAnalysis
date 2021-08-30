clc
clear all
close all

set(0,'defaultAxesFontSize',18)

Rootdir='My base Matlab directory';

ARAdir='Where I saved the area function (.ara)';
Datadir='Where I saved the data (.txt)';
PRMdir='Where I saved the parameters file (.prm)';

addpath 'My base Matlab directory'

%% Reading
%Read PRM Info for Cutting
[SRNum, Strains, EndTimes, PPSeg, Freq]=ReadPRM(PRMdir);

%Read Data
cd(Datadir)
files=dir('*.txt');
nfiles=length(files);

RawHardness=cell(nfiles,1);
RawStorMod=cell(nfiles,1);
RawLoad=cell(nfiles,1);
RawTime=cell(nfiles,1);
RawDisp=cell(nfiles,1);
RawStiff=cell(nfiles,1);
RawFreq=cell(nfiles,1);
RawDispAmp=cell(nfiles,1);

for FileNumber=1:nfiles
    DYNcurrentname=files(FileNumber).name;
    DYNcurrentfile=dlmread(DYNcurrentname,'\t',3,0);
    %Index of storage modulus in my file
    ModLoc=size(DYNcurrentfile,2)-10;
    RawHardness{FileNumber}=DYNcurrentfile(:,ModLoc+2); 
    RawStorMod{FileNumber}=DYNcurrentfile(:,ModLoc);
    RawStiff{FileNumber}=DYNcurrentfile(:,ModLoc+2+3); 
    RawLoad{FileNumber}=DYNcurrentfile(:,3);
    RawDisp{FileNumber}=DYNcurrentfile(:,2);
    RawTime{FileNumber}=DYNcurrentfile(:,1);
    RawFreq{FileNumber}=DYNcurrentfile(:,ModLoc-5);
    RawDispAmp{FileNumber}=DYNcurrentfile(:,ModLoc-4);
end
cd(Rootdir)
%% Rezeroing
%Rezero all indents
[ZeroDisp,ZeroLoad,ZeroMod,ZeroHard]=ManualRezeroLD(RawDisp,RawLoad,RawStiff,ARAdir);
%% Reset times
%Sometimes the times need to be reset
for FileNumber=1:nfiles
    SegEnd=find(RawFreq{FileNumber}==Freq,1);
    TimeDif=RawTime{FileNumber}(SegEnd);
    RawTime{FileNumber}=RawTime{FileNumber}-TimeDif;
    %Times were offset by 14 points (correct accordingly)
    RawTime{FileNumber}=RawTime{FileNumber}+14/70;
end

%% Cutting and corrections
%Cut Hold and Unload
CutDisp1=CutAfter(ZeroDisp,RawTime,EndTimes(end));
CutLoad1=CutAfter(ZeroLoad,RawTime,EndTimes(end));
CutTime1=CutAfter(RawTime,RawTime,EndTimes(end));
CutStorMod1=CutAfter(ZeroMod,RawTime,EndTimes(end));
CutHardness1=CutAfter(ZeroHard,RawTime,EndTimes(end));

%Snip data from before a certain displacement (default 100 nm)
DispCut=200; %nm
CutDisp=CutBefore(CutDisp1,CutDisp1,DispCut);
CutLoad=CutBefore(CutLoad1,CutDisp1,DispCut);
CutTime=CutBefore(CutTime1,CutDisp1,DispCut);
CutStorMod=CutBefore(CutStorMod1,CutDisp1,DispCut);
CutHardness=CutBefore(CutHardness1,CutDisp1,DispCut);
clear CutDisp1 CutHardness1 CutLoad1 CutStorMod1 CutTime1

CSMLess=true;
%CSM-less Correction
if CSMLess==true
    %4th parameter (321) is expected modulus of 321 GPa for tungsten
    [hc,CSMLessHard,Ac]=PlasErrCorr(ARAdir,CutDisp,CutLoad,321);
end

NixGaoCorrection=true;
if NixGaoCorrection==true
    NixGaoData='Where I saved my Nix-Gao data';
    [hstar,H0]=NixGaoCSM(NixGaoData,ARAdir);
    NixGaoHard=cell(nfiles,1);
    for FileNumber=1:nfiles
        NixGaoHard{FileNumber}=CSMLessHard{FileNumber}./sqrt(1+hstar./hc{FileNumber});
    end
end

%% Save 
save('SRJData.mat')

%% SRJ Analysis
[VStar, SRS,Table]=SRJ_Analysis(PRMdir,'regression',NixGaoHard,CutStorMod,CutTime,CutLoad,CutDisp, ...
    'ReprodPlot',false,'ExamplePlot',10);

%% Load Data from previous analysis and manual rezero
load('SRJData.mat')


%% Plots
FileToPlot=1;

%Hardness-displacement plot
figure(1)
hold on
box on
CutPlot=plot(CutDisp{FileToPlot},CutHardness{FileToPlot},'k');
CutPlot.LineWidth=2;
CSMLessPlot=plot(CutDisp{FileToPlot},CSMLessHard{FileToPlot},'r');
CSMLessPlot.LineWidth=2;
NixGaoPlot=plot(CutDisp{FileToPlot},NixGaoHard{FileToPlot},'b');
NixGaoPlot.LineWidth=2;
legend([CutPlot CSMLessPlot NixGaoPlot],{'Uncorrected Data','Corrected for Plasticity Error','Corrected for Size Effect'},'location','northeast')

ylim([3 9])
xlim([200 700])
xlabel('Displacement (nm)')
ylabel('Hardness (GPa)')

%Modulus-displacement plot
figure(2)
hold on
box on
CutModPlot=plot(CutDisp{FileToPlot},CutStorMod{FileToPlot},'k');
CutModPlot.LineWidth=2;
Expected=plot([200 700],[321 321],'r-');
Expected.LineWidth=2;
ylim([0 400])
xlim([200 700])
xlabel('Displacement (nm)')
ylabel('Storage Modulus (GPa)')

%Load-displacement plot
figure(3)
hold on
box on
LDPlot=plot(ZeroDisp{FileToPlot},ZeroLoad{FileToPlot}/1000,'k');
LDPlot.LineWidth=2;
xlim([0 800])
ylim([0 85])
xlabel('Displacement (nm)')
ylabel('Load (mN)')


figure(4)
hold on
box on
LDFPlot=plot(RawTime{FileToPlot},RawLoad{FileToPlot}/1000,'k');
LDFPlot.LineWidth=2;
xlim([0 100])
ylim([0 85])
xlabel('Time (s)')
ylabel('Load (mN)')

%% Analysis of VStar data
AvgSRSJump=mean(SRS,2);
StdSRSJump=std(SRS,0,2);

AvgVStarJump=mean(VStar,2);
StdVStarJump=std(VStar,0,2);

b=0.274e-9; %m, tungsten
AvgVStarJumpb3=AvgVStarJump/b^3;
StdVStarJumpb3=StdVStarJump/b^3;


AvgSRSAll=mean(SRS,'all');
StdSRSAll=std(SRS,0,'all');

AvgVStarAll=mean(VStar,'all')/b^3;
StdVStarAll=std(VStar,0,'all')/b^3;
