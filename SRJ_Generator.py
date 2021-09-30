"""
Load Controlled/Open Loop Strain Rate Jump Load Function Generator by Kevin Schmalbach
To be used with the Hysitron TI980 Nanoindenter

If used in publications, please cite: _________________________
Maintained at: https://github.com/KSchmalbach/IndentationAnalysis

"""
from math import log, exp, sqrt, pi, floor
import sys
import os
import tkinter as tk
from tkinter import filedialog
import matplotlib.pyplot as plt


class App(tk.Frame):
    def __init__(self, master=None):
        super().__init__(master)
        self.pack()
        self.createWidgets()

    def createWidgets(self):
        def EnterSRNum(SRNum):
            if SRNumBox.get() != '':
                SRNum=int(floor(float(SRNumBox.get())))
            if SRNum>0:
                SRandEndLoads(SRNum)
                return SRNum
            else:
                SRNumError()

        def SRNumError():
            ErrorPopUp=tk.Toplevel(self)
            tk.Label(ErrorPopUp,text='Please enter positive integer number of strain rates').grid(row=1,column=0)
            Close=tk.Button(ErrorPopUp,text='CLOSE',command=lambda:ErrorPopUp.destroy())
            Close.grid(row=2,column=0)

        def SRandEndLoads(SRNum):
            SRPopUp=tk.Toplevel(self)
            SRVals=[]
            SR=[]
            LoadVals=[]
            Load=[]  
            global HLorLLSel
            global OLorLCSel
            if 'StrainRates' not in globals() or len(StrainRates)!=SRNum:
                if HLorLLSel.get()==1 and OLorLCSel.get()==0: #High load, open loop
                    for i in range(SRNum):
                        SRVals.append(tk.StringVar())
                        SR.append(tk.Entry(SRPopUp,textvariable=SRVals[i]).grid(row=i,column=1))
                        tk.Label(SRPopUp,text='Strain rate #' +str(i+1) +' (1/s): ').grid(row=i,column=0)
                        LoadVals.append(tk.StringVar())
                        Load.append(tk.Entry(SRPopUp,textvariable=LoadVals[i]).grid(row=i,column=4))
                        tk.Label(SRPopUp,text='End disp #' +str(i+1) +' (nm): ').grid(row=i,column=3)    
                else:
                    for i in range(SRNum):
                        SRVals.append(tk.StringVar())
                        SR.append(tk.Entry(SRPopUp,textvariable=SRVals[i]).grid(row=i,column=1))
                        tk.Label(SRPopUp,text='Strain rate #' +str(i+1) +' (1/s): ').grid(row=i,column=0)
                        LoadVals.append(tk.StringVar())
                        Load.append(tk.Entry(SRPopUp,textvariable=LoadVals[i]).grid(row=i,column=4))
                        tk.Label(SRPopUp,text='End load #' +str(i+1) +' (microN): ').grid(row=i,column=3)
            else:
                if HLorLLSel.get()==1 and OLorLCSel.get()==0: #High load, open loop
                    for i in range(SRNum):
                        SRVals.append(tk.StringVar(value=str(StrainRates[i])))
                        LoadVals.append(tk.StringVar(value=str(EndLoads[i])))            
                        SR.append(tk.Entry(SRPopUp,textvariable=SRVals[i]).grid(row=i,column=1))
                        tk.Label(SRPopUp,text='Strain rate #' +str(i+1) +' (1/s): ').grid(row=i,column=0)
                        Load.append(tk.Entry(SRPopUp,textvariable=LoadVals[i]).grid(row=i,column=4))
                        tk.Label(SRPopUp,text='End disp #' +str(i+1) +' (nm): ').grid(row=i,column=3)
                else:    
                    for i in range(SRNum):
                        SRVals.append(tk.StringVar(value=str(StrainRates[i])))
                        LoadVals.append(tk.StringVar(value=str(EndLoads[i])))            
                        SR.append(tk.Entry(SRPopUp,textvariable=SRVals[i]).grid(row=i,column=1))
                        tk.Label(SRPopUp,text='Strain rate #' +str(i+1) +' (1/s): ').grid(row=i,column=0)
                        Load.append(tk.Entry(SRPopUp,textvariable=LoadVals[i]).grid(row=i,column=4))
                        tk.Label(SRPopUp,text='End load #' +str(i+1) +' (microN): ').grid(row=i,column=3)
            #global PInLoad
            if 'PInLoad' not in globals():
                PInLoadIntVar=tk.IntVar()
            else:
                PInLoadIntVar=tk.IntVar(value=PInLoad)
            PInBox=tk.Entry(SRPopUp,textvariable=PInLoadIntVar)
            PInBox.grid(row=i+1,column=3)
            if HLorLLSel.get()==1 and OLorLCSel.get()==0: #High load, open loop
                tk.Label(SRPopUp,text='Pop-In Displacement (nm): ').grid(row=i+1,column=1)
            else:
                tk.Label(SRPopUp,text='Pop-In Load (microN): ').grid(row=i+1,column=1)
            CloseBut=tk.Button(SRPopUp,text='Enter SRs and Loads',command=lambda:CheckSRs(SRVals,LoadVals,SRNum,SRPopUp,PInBox))
            CloseBut.grid(row=i+2,column=2)

        def CheckSRs(SRVals,LoadVals,SRNum,SRPopUp,PInBox):
            global StrainRates
            global EndLoads
            StrainRates=[]
            EndLoads=[]
            CheckBox=tk.Toplevel(self)
            CheckBox.title('Is this correct?')
            global PInLoad
            PInLoad=int(PInBox.get())
            global HLorLLSel
            global OLorLCSel
            if HLorLLSel.get()==1 and OLorLCSel.get()==0: #High load, open loop
                for i in range(SRNum):
                    StrainRates.append(SRVals[i].get())
                    EndLoads.append(LoadVals[i].get())
                    tk.Label(CheckBox,text='SR ' + str(i+1) +' (1/s): '+str(StrainRates[i])).grid(row=i,column=0)
                    tk.Label(CheckBox,text='Disp ' + str(i+1) +' (nm): '+str(EndLoads[i])).grid(row=i,column=3)    
            else:        
                for i in range(SRNum):
                    StrainRates.append(SRVals[i].get())
                    EndLoads.append(LoadVals[i].get())
                    tk.Label(CheckBox,text='SR ' + str(i+1) +' (1/s): '+str(StrainRates[i])).grid(row=i,column=0)
                    tk.Label(CheckBox,text='Load ' + str(i+1) +' (microN): '+str(EndLoads[i])).grid(row=i,column=3)
            tk.Button(CheckBox,text='Confirm',fg='green',command=lambda:Destroyer(CheckBox,SRPopUp)).grid(row=i+1,column=1)
            tk.Button(CheckBox,text='Return',fg='red',command=lambda:CheckBox.destroy()).grid(row=i+1,column=2)

        def Destroyer(CheckBox,SRPopUp):
            CheckBox.destroy()
            SRPopUp.destroy()

        def BoxesFilled():
            if type(HLorLLSel) != int:
                HLorLLSel==HLorLLSel.get()
            #Check that each parameter has a value
            if AmpBox.get()=='' or SRNumBox.get()=='' or FreqBox.get()=='' \
                or PPSegBox.get()=='' or FileBox.get()=='' or StrainRates==[] or EndLoads==[]:
                FillError()
            elif int(BerkOrSphere.get())==1: #Check for required parameters for spherical
                if RedModBox.get()=='' or TipRadBox.get()=='':
                    FillError()
            elif float(FreqBox.get())>301.5 and HLorLLSel==0: #low load head only goes to 301.5 Hz
                FreqError()
            elif float(FreqBox.get())>101.5 and HLorLLSel==1: #high load head only goes to 101.5 Hz
                FreqError()
            else:
                SegmentCheck(StrainRates,EndLoads,AmpScale,Plotting)

        def FreqError():
            FreqPopUp=tk.Toplevel(self)
            tk.Label(FreqPopUp,text='Frequency higher than maximum').grid(row=1,column=0)
            FreqClose=tk.Button(FreqPopUp,text='OK',command=lambda:FreqPopUp.destroy())
            FreqClose.grid(row=2,column=0)

        def FillError():
            FillPopUp=tk.Toplevel(self)
            tk.Label(FillPopUp,text='Please enter all parameters before continuing').grid(row=1,column=1)
            FillClose=tk.Button(FillPopUp,text='OK',command=lambda:FillPopUp.destroy())
            FillClose.grid(row=2,column=1)

        def SegmentCheck(StrainRates,EndLoads,AmpScale,Plotting):
            if type(HLorLLSel) != int:
                HLorLLSel==HLorLLSel.get()
            StartAmp=float(AmpBox.get())
            SRNum=int(SRNumBox.get())
            Freq=float(FreqBox.get())
            StrainRates=list(map(float,StrainRates))
            EndLoads=list(map(int,EndLoads))
            if BerkOrSphere.get()==1: #Spherical
                RedMod=float(RedModBox.get())
                TipRad=float(TipRadBox.get())
            PointsPerSeg=int(PPSegBox.get())
            TimePerStrain=[]
            if PInLoad !=0:
                InitialLoad=PInLoad
            else:
                InitialLoad=StartAmp+1
            LoadPoints=[InitialLoad]
            LoadSegmentEnds=[]
            #Make a list for the start points of each strain rate
            for i in range(len(EndLoads)):
                LoadSegmentEnds.append(EndLoads[i])
            #Calculate time for each strain rate
            if int(BerkOrSphere.get()==0): #Berkovich
                if HLorLLSel==1 and OLorLCSel.get()==0: #High load, open loop
                    for i in range(SRNum):
                        #this becomes displacements (hdot/h), so no 1/2
                        #Also the variable names are the same, but indicate displacements in this case
                        if i==0:
                            TimePerStrain.append(log(EndLoads[0]/LoadPoints[-1])/StrainRates[0])
                        else:
                            TimePerStrain.append(log(EndLoads[i]/EndLoads[i-1])/StrainRates[i])    
                else:
                    for i in range(SRNum):
                        if i==0:
                            TimePerStrain.append(0.5*log(EndLoads[0]/LoadPoints[-1])/StrainRates[0])
                        else:
                            TimePerStrain.append(0.5*log(EndLoads[i]/EndLoads[i-1])/StrainRates[i])
            else: #Spherical
                for i in range(SRNum):
                    if i==0:
                        Num=(EndLoads[0]**(1/3)-LoadPoints[-1]**(1/3))*3*(4/(9*pi))*(3/4)**(1/3)
                        Denom=StrainRates[0]*RedMod**(1/3)*TipRad**(2/3)*(1/1000)**(1/3) #1/1000^1/3 comes from unit conversion from TPa to GPa
                        TimePerStrain.append(Num/Denom)
                    else:
                        Num=(EndLoads[i]**(1/3)-EndLoads[i-1]**(1/3))*3*(4/(9*pi))*(3/4)**(1/3)
                        Denom=StrainRates[i]*RedMod**(1/3)*TipRad**(2/3)*(1/1000)**(1/3) #1/1000^1/3 comes from unit conversion from TPa to GPa
                        TimePerStrain.append(Num/Denom)
            TotalTime=sum(TimePerStrain)
            NumberofSegments=int(TotalTime*Freq/PointsPerSeg)
            #If too many loading segments, abort making function, otherwise make the function
            if NumberofSegments>2000:
                TooManySeg=tk.Toplevel(self)
                tk.Label(TooManySeg,text='Too many load segments: please make changes and try again').grid(row=1,column=1)
                tk.Button(TooManySeg,text='Return',fg='red',command=lambda:TooManySeg.destroy()).grid(row=2,column=1)
            elif int(Plotting.get())==1:
                (TimePoints, LoadPoints, Amp)=AllCalcs(HLorLLSel,StrainRates,EndLoads,PInLoad,AmpScale)
                NewPlot(TimePoints,LoadPoints,InitialLoad,Amp)
            else:
                (TimePoints, LoadPoints, Amp)=AllCalcs(HLorLLSel,StrainRates,EndLoads,PInLoad,AmpScale)
                WriteLDF(HLorLLSel,Freq,LoadPoints,TimePoints,Amp)
                #MakeLDF(HLorLLSel,StrainRates,EndLoads,PInLoad,AmpScale)

        def NewPlot(TimePoints,LoadPoints,InitialLoad,Amp):
            PreloadTime=float(PreloadTimeBox.get())
            DwellTime=float(DwellBox.get())
            PlotTimePoints=[0,PreloadTime]
            for i in range(len(TimePoints)):
                PlotTimePoints.append(TimePoints[i])
            PlotTimePoints.append(TimePoints[-1]+2) #Hold time of 2 seconds
            PlotTimePoints.append(TimePoints[-1]+2+5) #Hold of 2 s, unload of 5 s
            PlotLoadPoints=[0,InitialLoad]
            for i in range(len(LoadPoints)):
                PlotLoadPoints.append(LoadPoints[i])
            PlotLoadPoints.append(LoadPoints[-1]) #hold
            PlotLoadPoints.append(0) #unload
            plt.plot(PlotTimePoints,PlotLoadPoints)
            plt.xlabel('Time (s)')
            if type(HLorLLSel) != int:
                HLorLLSel==HLorLLSel.get()
            if HLorLLSel==1 and OLorLCSel.get()==0: #High load, open loop
                plt.ylabel('Displacement (nm)')
            else:    
                plt.ylabel('Load ($\mu$N)')
            plt.show()
            global PlotCheck
            PlotCheck=tk.Toplevel(self)
            tk.Label(PlotCheck,text='Proceed with .ldf creation?').grid(row=1,column=1)
            tk.Button(PlotCheck,text='Proceed',fg='green',command=lambda:WriteLDF(HLorLLSel,Freq,LoadPoints,TimePoints,Amp)).grid(row=1,column=2)
            tk.Button(PlotCheck,text='Cancel',fg='red',command=lambda:PlotCheck.destroy()).grid(row=1,column=3)

            
        def AllCalcs(HLorLLSel,StrainRates,EndLoads,PInLoad,AmpScale):
            if type(HLorLLSel) != int:
                HLorLLSel==HLorLLSel.get()
            Freq=float(FreqBox.get())
            StartAmp=float(AmpBox.get())
            SRNum=int(SRNumBox.get())
            StrainRates=list(map(float,StrainRates))
            EndLoads=list(map(int,EndLoads))
            PInLoad=int(PInLoad)
            PointsPerSeg=int(PPSegBox.get())
            if BerkOrSphere.get()==1: #Spherical
                RedMod=float(RedModBox.get())
                TipRad=float(TipRadBox.get())
            global AmpScaleVal
            AmpScaleVal=float(AmpScaleBox.get())
            if PInLoad != 0:
                InitialLoad=PInLoad
            else:
                InitialLoad=StartAmp+1
            #Initialize lists that will be appended later
            TimePerStrain=[]
            TimePerSegment=[]
            SegmentsPerStrain=[]
            Amp=[StartAmp]
            #Allow lift, reseek, and dwell times to vary
            DwellTime=float(DwellBox.get())
            PreloadTime=float(PreloadTimeBox.get())
            LoadingStartTime=PreloadTime+DwellTime
            TimePoints=[LoadingStartTime]
            LoadPoints=[InitialLoad]
            LoadSegmentEnds=[]
            

            ## Taken out 8/16/21
            #if PInLoad!=0:
             #   TimePoints.append(LoadingStartTime+4)
              #  LoadPoints.append(PInLoad)
               # Amp.append(StartAmp)
                #LoadSegmentEnds=[InitialLoad]

            #Make a list for the start points of each strain rate
            for i in range(len(EndLoads)):
                LoadSegmentEnds.append(EndLoads[i])
            #Calculate time for each strain rate
            if int(BerkOrSphere.get()==0): #Berkovich
                if HLorLLSel==1 and OLorLCSel.get()==0: #High load, open loop
                    for i in range(SRNum):
                        if i==0:
                            TimePerStrain.append(log(EndLoads[0]/LoadPoints[-1])/StrainRates[0])
                            SegmentsPerStrain.append(int(Freq*TimePerStrain[0]/PointsPerSeg))
                        else:
                            TimePerStrain.append(log(EndLoads[i]/EndLoads[i-1])/StrainRates[i])
                            SegmentsPerStrain.append(int(Freq*TimePerStrain[i]/PointsPerSeg))
                else:    
                    for i in range(SRNum):
                        if i==0:
                            TimePerStrain.append(0.5*log(EndLoads[0]/LoadPoints[-1])/StrainRates[0])
                            SegmentsPerStrain.append(int(Freq*TimePerStrain[0]/PointsPerSeg))
                        else:
                            TimePerStrain.append(0.5*log(EndLoads[i]/EndLoads[i-1])/StrainRates[i])
                            SegmentsPerStrain.append(int(Freq*TimePerStrain[i]/PointsPerSeg))
            else: #Spherical
                for i in range(SRNum):
                    if i==0:
                        Num=(EndLoads[0]**(1/3)-LoadPoints[-1]**(1/3))*3*(4/(9*pi))*(3/4)**(1/3)
                        Denom=StrainRates[0]*RedMod**(1/3)*TipRad**(2/3)*(1/1000)**(1/3) #1/1000^1/3 comes from unit conversion from TPa to GPa
                        TimePerStrain.append(Num/Denom)
                        SegmentsPerStrain.append(int(Freq*TimePerStrain[0]/PointsPerSeg))
                    else:
                        Num=(EndLoads[i]**(1/3)-EndLoads[i-1]**(1/3))*3*(4/(9*pi))*(3/4)**(1/3)
                        Denom=StrainRates[i]*RedMod**(1/3)*TipRad**(2/3)*(1/1000)**(1/3) #1/1000^1/3 comes from unit conversion from TPa to GPa
                        TimePerStrain.append(Num/Denom)
                        SegmentsPerStrain.append(int(Freq*TimePerStrain[i]/PointsPerSeg))
            global EndTimes
            EndTimes=[]
            for i in range(SRNum):
                if i==0:
                    EndTimes.append(LoadingStartTime+TimePerStrain[i])
                else:
                    EndTimes.append(EndTimes[-1]+TimePerStrain[i])

            #Divide time per strain rate to get time per loading segment
            for i in range(len(TimePerStrain)):
                TimePerSegment.append(TimePerStrain[i]/SegmentsPerStrain[i])
            #Calculate all the time and load points for each segment
            if int(BerkOrSphere.get()==0): #Berkovich
                if HLorLLSel==1 and OLorLCSel.get()==0: #High load, open loop
                    for i in range(SRNum):
                        for j in range(SegmentsPerStrain[i]):
                            TimePoints.append(TimePoints[-1]+TimePerSegment[i])
                            LoadPoints.append(LoadPoints[-1]*exp(StrainRates[i]*(TimePoints[-1]-TimePoints[-2])))
                            Amp.append(StartAmp*(LoadPoints[-1]/LoadPoints[1])**AmpScaleVal)
                else:
                    for i in range(SRNum):
                        for j in range(SegmentsPerStrain[i]):
                            TimePoints.append(TimePoints[-1]+TimePerSegment[i])
                            LoadPoints.append(LoadPoints[-1]*exp(2*StrainRates[i]*(TimePoints[-1]-TimePoints[-2])))
                            Amp.append(StartAmp*(LoadPoints[-1]/LoadPoints[1])**AmpScaleVal)
            else: #Spherical            
                for i in range(SRNum):
                    for j in range(SegmentsPerStrain[i]):
                        TimePoints.append(TimePoints[-1]+TimePerSegment[i])
                        LoadNum=StrainRates[i]*RedMod**(1/3)*TipRad**(2/3)*(1/1000)**(1/3)
                        LoadDenom=3*(4/(9*pi))*(3/4)**(1/3)
                        LoadPoints.append((LoadNum*(TimePoints[-1]-TimePoints[-2])/LoadDenom+LoadPoints[-1]**(1/3))**3)
                        Amp.append(StartAmp*(LoadPoints[-1]/LoadPoints[1])**AmpScaleVal)
            return (TimePoints, LoadPoints, Amp)

        def ReadPRM(SRNumBox,FreqBox,AmpBox,PPSegBox):
            InPRM=filedialog.askopenfilename(initialdir=os.getcwd(),title='Select .prm',filetypes=(('Params file (.prm)','*.prm'),('All files','*.*')))
            PRM=open(InPRM,'r')
            PRMLines=PRM.readlines()
            SRNumPRM=PRMLines[0].split('\t')
            SRNumPRM=SRNumPRM[1].split('\n')
            SRNumPRM=int(SRNumPRM[0])
            FreqPRM=PRMLines[1].split('\t')
            FreqPRM=FreqPRM[1].split('\n')
            FreqPRM=float(FreqPRM[0])
            AmpPRM=PRMLines[2].split('\t')
            AmpPRM=AmpPRM[1].split('\n')
            AmpPRM=float(AmpPRM[0])
            global PInLoad
            PInLoad=0
            #Points per segment weren't originally in PRM
            if len(PRMLines)>3*SRNumPRM+3:
                PPSegPRM=PRMLines[2+3*SRNumPRM+1].split('\t')
                PPSegPRM=PPSegPRM[1].split('\n')
                PPSegPRM=int(PPSegPRM[0])
                NewPPSeg=tk.StringVar(value=PPSegPRM)
                PPSegBox.config(textvariable=NewPPSeg)
                #Amplitude scaling added later
                if len(PRMLines)>3*SRNumPRM+4:
                    AmpScalePRM=PRMLines[2+3*SRNumPRM+2].split('\t')
                    AmpScalePRM=AmpScalePRM[1].split('\n')
                    AmpScalePRM=float(AmpScalePRM[0])
                    NewScale=tk.StringVar(value=AmpScalePRM)
                    AmpScaleBox.config(textvariable=NewScale)
                    #Popin load added to PRM later
                    if len(PRMLines)>3*SRNumPRM+5:
                        PInLoadPRM=PRMLines[2+3*SRNumPRM+3].split('\t')
                        PInLoadPRM=PInLoadPRM[1].split('\n')
                        PInLoad=int(PInLoadPRM[0])
                        #Additional check for spherical parameters
                        if len(PRMLines)>3*SRNumPRM+6:
                            ErPRM=PRMLines[2+3*SRNumPRM+4].split('\t')
                            ErPRM=ErPRM[1].split('\n')
                            Er=int(ErPRM[0])
                            TipRPRM=PRMLines[2+3*SRNumPRM+5].split('\t')
                            TipRPRM=TipRPRM[1].split('\n')
                            TipR=float(TipRPRM[0])
                            NewEr=tk.StringVar(value=Er)
                            RedModBox.config(textvariable=NewEr)
                            NewR=tk.StringVar(value=TipR)
                            TipRadBox.config(textvariable=NewR)
            global StrainRates
            global EndLoads
            StrainRates=[]
            EndLoads=[]
            for i in range(SRNumPRM):
                SRLinePRM=PRMLines[2+i+1].split('\t')
                LoadLinePRM=PRMLines[2+SRNumPRM+i+1].split('\t')
                SRLinePRM=SRLinePRM[1].split('\n')
                LoadLinePRM=LoadLinePRM[1].split('\n')
                LoadLinePRM=LoadLinePRM[0].split('.')
                StrainRates.append(float(SRLinePRM[0]))
                EndLoads.append(int(LoadLinePRM[0]))

            PRM.close()
            NewSRNum=tk.StringVar(value=SRNumPRM)
            SRNumBox.config(textvariable=NewSRNum)
            NewFreq=tk.StringVar(value=FreqPRM)
            FreqBox.config(textvariable=NewFreq)
            NewAmp=tk.StringVar(value=AmpPRM)
            AmpBox.config(textvariable=NewAmp)
            


        def WriteHeader(ldf,numsegs):
            global HLorLLSel
            HLorLL=HLorLLSel.get()
            Freq=float(FreqBox.get())
            LiftTime=float(LiftBox.get())
            LiftHeight=float(LiftHeightBox.get())
            LiftGain=float(LiftGainBox.get())
            LiftDataPoints=200*LiftTime
            ReseekTime=float(ReseekBox.get())
            ReseekDataPoints=200*ReseekTime
            
            if HLorLL==1:
                #Set high load
                HLorLL=1
                PreloadGain=0.1
            else:
                #Set low load
                HLorLL=0
                PreloadGain=0.2
            ApproachOffsetX=float(ApproachOffsetXBox.get())/1000 #divide by 1000 to get to mm
            ApproachOffsetY=float(ApproachOffsetYBox.get())/1000 #divide by 1000 to get to mm
            ldf.write('File Version: Hysitron Load Function version 9.0 Release\n\
' + str(HLorLL)+ '\t:Low(0) or HighLoad(1)\n')
            if OLorLCSel.get()==0:
                ldf.write('0\t:Openloop no feedback\n')
            else:
                ldf.write('5\t:Load Control feedback\n')
            ldf.write('2.0	:PreLoadVal\n\
40.0	:DriftMonitorTime\n\
20.0	:DriftAnalysisTime\n\
' +str(LiftHeight) + '\t:LiftHeight\n\
5.0	:ApproachRate:\n\
0.0	:ScratchLength\n\
0.0	:ScratchAngle\n\
1	:UserMode\n\
1	:UseSetpointForPreload\n\
1	:UseApproachOffset\n\
' +str(ApproachOffsetX) + '\t:XApproachOffset\n\
' +str(ApproachOffsetY) + '\t:YApproachOffset\n\
0.0	:PreDispVal\n\
0	:PreDispType\n\
' + str(PreloadGain)+ '\t:PreLoadFBGain\n\
' + str(LiftGain)+ '\t:LiftFBGain\n\
0.0	:AdaptiveFBGain\n\
0.0	:ProportionalFBGain\n\
1.0	:IntegralFBGain\n\
0.0	:DerivativeFBGain\n\
0	:IncludeOpenLoopTerm\n\
1024	:MaxDataPts\n\
0	:NumRepeats\n\
0.05	:targetdriftrate\n\
1.0	:settletime\n\
' + str(LiftTime)+ '\t:lifttime\n\
' + str(LiftDataPoints)+ '\t:liftnumofpoints\n\
' + str(ReseekTime)+ '\t:reseektime\n\
' + str(ReseekDataPoints)+ '\t:reseeknumofpoints\n\
2.0	:approachtime\n\
0	:qdisable\n\
0	:DriftMode\n\
22	:nudsmsensitivity\n\
0	:nudsmrefmodulustype\n\
1	:referencemodulusfrom\n\
1	:nudsmlockinmode\n\
0	:applydynamicpreload0\n\
0	:applydynamicpreload1\n\
2	:filterslope\n\
1	:reserve\n\
0	:coupling\n\
0	:dualmode\n\
0	:noisemeasurement\n\
8	:lockintype\n\
220.0	:nudsmreffreq\n\
69.6	:nudsmrefmodulus\n\
200.0	:rollofftimeconstants\n\
1	:preloadautosettings\n\
1	:numfilter\n\
8	:averaging\n\
0	:gain\n\
-1.0	:preloadtimeconsval0\n\
0.3	:preloaddynamicforce0\n\
15.92	:preloadcutofffreq0\n\
200.0	:preloadfrequency0\n\
0.2	:preloadnotchq0\n\
-1.0	:preloadtimeconsval1\n\
0.3	:preloaddynamicforce1\n\
15.92	:preloadcutofffreq1\n\
200.0	:preloadfrequency1\n\
0.2	:preloadnotchq1\n\
1	:Number to Average\n\
END OF HEADER\n\
\n' + str(numsegs-1+4) + '\t:NumofSegments\n\n') #4 from preload, dwell, hold, unload


        def WriteSegment(ldf,duration,startTime,endTime,startLoad,endLoad,numPoints,acqRate):
            ldf.write('\
0	:SegmentType\n\
' + str(duration)	+ '\t:SegmentTime\n\
' + str(startTime) + '\t:BeginTime\n\
' + str(endTime) +'\t:EndTime\n\
' + str(startLoad) +'\t:BeginLoad\n\
' + str(endLoad) + '\t:EndLoad\n\
' + str(numPoints) + '\t:NumofSeqPoints\n\
' + str(acqRate) + '\t:Aquisition_rate\n\n')

        def WriteNotchq0(ldf,segType,TC,Amp,Freq):
            ldf.write('\
'+ str(segType) +'\t:segmenttype0\n\
2	:loadvarytype0\n\
'+ str(TC) + '\t:timeconst0\n\
'+ str(Freq) + '\t:frequency0\n\
'+ str(Amp) + '\t:dynamicload0\n\
7.96	:cutofffreq0\n\
0.2	:notchq0\n')
        
        def WriteNotchq1(ldf,TC,BaseFreq,AmpStart):
            ldf.write('\
1	:segmenttype1\n\
3	:loadvarytype1\n\
' + str(TC) + '\t:timeconst1\n\
' + str(BaseFreq) + '\t:frequency1\n\
' + str(AmpStart) + '\t:dynamicload1\n\
15.92\t:cutofffreq1\n\
0.2\t:notchq1\n')

        def WriteLDF(HLorLLSel,Freq,LoadPoints,TimePoints,Amp):
            if 'PlotCheck' in globals():
                if tk.Toplevel.winfo_exists(PlotCheck):
                    PlotCheck.destroy()
            #InitialLoad=float(AmpBox.get())+1
            if PInLoad != 0:
                InitialLoad=PInLoad
            else:
                InitialLoad=float(AmpBox.get())+1
            Freq=float(FreqBox.get())
            AcqRate=Freq #Tie Acquisition rate to oscillation frequency to sample same point on sinusoid
            #List of time constants
            if Freq <= 0.9:
                TC=1.5
            elif Freq <= 3.0:
                TC=0.5
            elif Freq <= 9.0:
                TC=0.15
            elif Freq <= 30.0:
                TC=0.05
            elif Freq <= 100.0:
                TC=0.015
            else:
                TC=0.005
            FileName=str(FileBox.get())
            TxtFilename=FileName + '.ldf'
            #Make file
            ldf=open(TxtFilename,'w')
            DwellTime=float(DwellBox.get())
            DwellDataPoints=200*DwellTime
            #Write header
            WriteHeader(ldf,len(TimePoints))
            #Write preload, dwell
            PreloadTime=float(PreloadTimeBox.get())
            WriteSegment(ldf,PreloadTime,0,PreloadTime,0,InitialLoad,PreloadTime*200,200)
            WriteSegment(ldf,DwellTime,PreloadTime,PreloadTime+DwellTime,InitialLoad,InitialLoad,DwellDataPoints,200)
            #Write loading segments
            for i in range(1,len(TimePoints)):
                SegmentTime=round(TimePoints[i]-TimePoints[i-1],2)
                NumberOfPoints=int(AcqRate*SegmentTime)
                WriteSegment(ldf,SegmentTime,TimePoints[i-1],TimePoints[i],LoadPoints[i-1],LoadPoints[i],NumberOfPoints,AcqRate)
            #Write hold, unload
            HoldTime=2
            UnloadTime=5
            WriteSegment(ldf,HoldTime,TimePoints[-1],TimePoints[-1]+HoldTime,EndLoads[-1],EndLoads[-1],int(AcqRate*HoldTime),AcqRate)
            WriteSegment(ldf,UnloadTime,TimePoints[-1]+HoldTime,TimePoints[-1]+HoldTime+UnloadTime,EndLoads[-1],0,int(AcqRate*UnloadTime),AcqRate)

            #NuDSM (Dynamic)
            ldf.write('START OF NuDSM 4.0\n')
            #notchq0
            #segment type 1=quasi, 2=DMA
            #Preload, dwell
            WriteNotchq0(ldf,1,TC,Amp[0],Freq)
            WriteNotchq0(ldf,2,TC,Amp[0],Freq)
            #Loading segments
            for i in range(1,len(TimePoints)):
                WriteNotchq0(ldf,2,TC,Amp[i],Freq)
            #Hold, unload
            WriteNotchq0(ldf,1,TC,Amp[-1],Freq)
            WriteNotchq0(ldf,1,TC,Amp[-1],Freq)
            #notchq1
            #Preload, dwell
            WriteNotchq1(ldf,TC,200,Amp[0])
            WriteNotchq1(ldf,TC,200,Amp[0])
            #Loading segments
            for i in range(1,len(TimePoints)):
                WriteNotchq1(ldf,TC,200,Amp[0])
            #Hold, unload
            WriteNotchq1(ldf,TC,200,Amp[0])
            WriteNotchq1(ldf,TC,200,Amp[0])

            #Time Constant Table
            ldf.write('\n\
6	:Number of Time Constant Entries\n\
1.5	:Time Constant Value\n\
0.9	:Upto Frequency\n\
0.5	:Time Constant Value\n\
3.0	:Upto Frequency\n\
0.15	:Time Constant Value\n\
9.0	:Upto Frequency\n\
0.05	:Time Constant Value\n\
30.0	:Upto Frequency\n\
0.015	:Time Constant Value\n\
100.0	:Upto Frequency\n\
0.005	:Time Constant Value\n\
1000.0	:Upto Frequency\n')


            WritePRM(FileName,Freq,Amp)
            Confirmation=tk.Toplevel(self)
            tk.Label(Confirmation,text='Load function created successfully').grid(row=0,column=0)
            tk.Button(Confirmation,text='Close',command=lambda:Confirmation.destroy()).grid(row=1,column=0)

        def WritePRM(FileName,Freq,Amp):
            PrmFilename=FileName+'.prm'
            StartAmp=Amp[0]
            SRNum=int(SRNumBox.get())
            PointsPerSeg=int(PPSegBox.get())
            #StrainRates=list(map(float,StrainRates))
            #EndLoads=list(map(int,EndLoads))
            #Create a different text file that shows inputs
            g=open(PrmFilename,'w')
            g.write('\
Number of Strain Rates:\t' + str(SRNum) +'\n\
Frequency:\t' + str(Freq)+ '\n\
Amplitude:\t' + str(StartAmp) + '\n')
            for i in range(1,len(StrainRates)+1):
                g.write('\
Strain Rate ' + str(i) + ':\t' + str(StrainRates[i-1]) + '\n')
            for i in range(1,len(StrainRates)+1):
                g.write('\
End Load ' + str(i) + ':\t' + str(EndLoads[i-1]) + '\n')
            for i in range(1,len(EndTimes)+1):
                g.write('\
End Time ' + str(i) + ':\t' + str(EndTimes[i-1]) + '\n')
            g.write('\
Points per segment:\t' + str(PointsPerSeg) + '\n')
            g.write('\
Amplitude scaling:\t' + str(AmpScaleVal) + '\n')    
            g.write('\
Popin Load:\t' + str(PInLoad) + '\n')
            if int(BerkOrSphere.get()==1): #Spherical
                g.write('\
Reduced Modulus:\t' + str(RedModBox.get()) + '\n')
                g.write('\
Tip Radius:\t' + str(TipRadBox.get()) + '\n')

        #Base parameters
        global OLorLCSel
        OLorLCSel=tk.IntVar()
        tk.Radiobutton(self,text='Open loop',variable=OLorLCSel,value=0).grid(row=0,column=1)
        tk.Radiobutton(self,text='Load control',variable=OLorLCSel,value=1).grid(row=0,column=3)
        global HLorLLSel
        HLorLLSel=tk.IntVar()
        tk.Radiobutton(self,text='Low load',variable=HLorLLSel,value=0).grid(row=1,column=1)
        tk.Radiobutton(self,text='High load',variable=HLorLLSel,value=1).grid(row=1,column=3)
        global BerkOrSphere
        BerkOrSphere=tk.IntVar()
        tk.Radiobutton(self,text="Berkovich",variable=BerkOrSphere,value=0).grid(row=2,column=1)
        tk.Radiobutton(self,text="Spherical",variable=BerkOrSphere,value=1).grid(row=2,column=3)
        global SRNum
        SRNum=tk.StringVar()
        SRNumBox=tk.Entry(self,textvariable=SRNum)
        SRNumBox.grid(row=3,column=3)
        SRBut=tk.Button(self,text='Add Strain Rates',command=lambda:EnterSRNum(SRNum))
        SRBut.grid(row=3,column=4)
        tk.Label(self,text='Number of Strain Rates:').grid(row=3,column=1)
        global Freq
        Freq=tk.StringVar()
        FreqBox=tk.Entry(self,textvariable=Freq)
        FreqBox.grid(row=4,column=3)
        tk.Label(self,text='Oscillation frequency (Hz): ').grid(row=4,column=1)
        global PointsPerSeg
        PointsPerSeg=tk.StringVar()
        PPSegBox=tk.Entry(self,textvariable=PointsPerSeg)
        PPSegBox.grid(row=5,column=3)
        tk.Label(self,text='Points per loading segment: ').grid(row=5,column=1)
        global StartAmp
        StartAmp=tk.StringVar()
        AmpBox=tk.Entry(self,textvariable=StartAmp)
        AmpBox.grid(row=6,column=3)
        tk.Label(self,text='Oscillation Amplitude: ').grid(row=6,column=1)
        global AmpScale
        AmpScale=tk.StringVar()
        tk.Label(self,text='Amplitude Scaling Exponent:').grid(row=7,column=1)
        AmpScaleBox=tk.Entry(self,textvariable=AmpScale)
        AmpScaleBox.grid(row=7,column=3)
        global FileName
        FileName=tk.StringVar()
        FileBox=tk.Entry(self,textvariable=FileName)
        FileBox.grid(row=8,column=3)
        tk.Label(self,text='File name: ').grid(row=8,column=1)
        global Plotting
        Plotting=tk.IntVar()
        tk.Label(self,text='Show Plot?').grid(row=9,column=1)
        tk.Checkbutton(self,variable=Plotting, onvalue=1, offvalue=0).grid(row=9,column=2)
        
        #Spherical parameters
        tk.Label(self,text="Spherical:").grid(row=0,column=5)
        global RedMod   
        RedMod=tk.StringVar()
        tk.Label(self,text='Reduced Modulus (GPa):').grid(row=1,column=5)
        RedModBox=tk.Entry(self,textvariable=RedMod)
        RedModBox.grid(row=1,column=6)
        global TipRad
        TipRad=tk.StringVar()
        tk.Label(self,text='Tip Radius (nm):').grid(row=2,column=5)
        TipRadBox=tk.Entry(self,textvariable=TipRad)
        TipRadBox.grid(row=2,column=6)

        #Pre-times
        tk.Label(self,text='Pre-Times (s):').grid(row=4,column=5)
        global LiftTime, ReseekTime, DwellTime,  LiftGain, LiftHeight
        tk.Label(self,text='Lift:').grid(row=5,column=5)
        LiftTime=tk.StringVar(value='1')
        LiftBox=tk.Entry(self,textvariable=LiftTime)
        LiftBox.grid(row=5,column=6)
        tk.Label(self,text='Reseek:').grid(row=6,column=5)
        ReseekTime=tk.StringVar(value='3')
        ReseekBox=tk.Entry(self,textvariable=ReseekTime)
        ReseekBox.grid(row=6,column=6)
        tk.Label(self,text='Preload:').grid(row=7,column=5)
        PreloadTime=tk.StringVar(value='2')
        PreloadTimeBox=tk.Entry(self,textvariable=PreloadTime)
        PreloadTimeBox.grid(row=7,column=6)
        tk.Label(self,text='Dwell:').grid(row=8,column=5)
        DwellTime=tk.StringVar(value='2')
        DwellBox=tk.Entry(self,textvariable=DwellTime)
        DwellBox.grid(row=8,column=6)

        #Lift parameters
        tk.Label(self,text="Lift height (nm):").grid(row=5,column=7)
        LiftHeight=tk.StringVar(value='25')
        LiftHeightBox=tk.Entry(self,textvariable=LiftHeight)
        LiftHeightBox.grid(row=5,column=8)
        tk.Label(self,text='Lift Gain:').grid(row=6,column=7)
        LiftGain=tk.StringVar(value='0.5')
        LiftGainBox=tk.Entry(self,textvariable=LiftGain)
        LiftGainBox.grid(row=6,column=8)
        
        

        #Offset area
        tk.Label(self,text='Approach offset (microns):').grid(row=0,column=7)
        tk.Label(self,text='X:').grid(row=1,column=7)
        ApproachOffsetX=tk.StringVar(value='0')
        ApproachOffsetXBox=tk.Entry(self,textvariable=ApproachOffsetX)
        ApproachOffsetXBox.grid(row=1,column=8)
        tk.Label(self,text='Y:').grid(row=2,column=7)
        ApproachOffsetY=tk.StringVar(value='0')
        ApproachOffsetYBox=tk.Entry(self,textvariable=ApproachOffsetY)
        ApproachOffsetYBox.grid(row=2,column=8)
        
        #Buttons
        tk.Button(self,text='Make .ldf',fg='green',command=lambda:BoxesFilled()).grid(row=10,column=2)
        tk.Button(self,text='Read from .prm',command=lambda:ReadPRM(SRNumBox,FreqBox,AmpBox,PPSegBox)).grid(row=10,column=3)
        tk.Button(self,text="QUIT", fg="red",command=lambda:self.master.destroy()).grid(row=10,column=4)


root=tk.Tk()
app=App(master=root)
app.master.title('Strain Rate Jump Generator')
app.mainloop()
