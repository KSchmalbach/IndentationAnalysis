function DistIn=DistInFigure(Disp,Hardness,SegNum)

    set(0,'defaultAxesFontSize',12)
    warning('off','MATLAB:declareGlobalBeforeUse');
    global RegLinePlot
    global DistIn
    fig=uifigure('Name',strcat("Segment ",string(SegNum)),'Resize','off');
    [lbl,editbox,slider,saveButton]=CreateComponents(fig);
    NewAx=axes(fig,'Position',[0.11 0.22 0.775 0.715]);
    xlabel(NewAx,'Displacement (nm)')
    ylabel(NewAx,'Hardness (GPa)')
    hold(NewAx,'on')
    nfiles=length(Hardness);
    box(NewAx,'on')
    for FileNumber=1:nfiles
        plot(NewAx,Disp{FileNumber},Hardness{FileNumber},'ro');
    end
    RegLine=RerunRegression(Hardness,Disp,editbox.Value);
    RegLinePlot=PlotRegressions(NewAx,RegLine,Disp);
    editbox.ValueChangedFcn=@(txt,event) EditBoxChanged(txt,slider,RegLinePlot,Hardness,Disp,NewAx);
    slider.ValueChangedFcn=@(val,event) SliderChanged(val,editbox,RegLinePlot,Hardness,Disp,NewAx);
    saveButton.ButtonPushedFcn=@(but,event) SaveButtonPressed(but,editbox,fig);
    %Pause while waiting for figure close callback, then return slider value as
    %DistIn to add to array

    %pause('on')
    fig.CloseRequestFcn=@(~,event) CloseFig(fig,editbox);
    uiwait(fig)
end


function EditBoxChanged(txt,slider,RegLinePlot,Hardness,Disp,NewAx)
    global RegLinePlot
    slider.Value=round(txt.Value,2);
    children=get(NewAx,'children');
    delete(children(1:length(Disp)))
    delete(RegLinePlot(:))
    RegLine=RerunRegression(Hardness,Disp,slider.Value);
    %assignin('caller','RegLine',RegLine)
    RegLinePlot=PlotRegressions(NewAx,RegLine,Disp);
    %assignin('caller','RegLinePlot',RegLinePlot);
end

function SliderChanged(val,editbox,RegLinePlot,Hardness,Disp,NewAx)
    global RegLinePlot
    editbox.Value=round(val.Value,2);
    children=get(NewAx,'children');
    delete(children(1:length(Disp)))
    delete(RegLinePlot(:))
    RegLine=RerunRegression(Hardness,Disp,editbox.Value);
    %assignin('caller','RegLine',RegLine)
    RegLinePlot=PlotRegressions(NewAx,RegLine,Disp);
    %assignin('caller','RegLinePlot',RegLinePlot);
end

function SaveButtonPressed(but,editbox,fig)
    pause('off') 
    global DistIn
    DistIn=editbox.Value;
    %assignin('base','DistIn',editbox.Value)
    delete(fig) 
end

function RegLine=RerunRegression(Hardness,Disp,DistIn)
    for FileNumber=1:length(Hardness)
        nPoints=length(Disp{FileNumber}); %Number of data points in segment
        In=round(DistIn*nPoints); %Index to start regression
        Reg=polyfit(Disp{FileNumber}(In:end),Hardness{FileNumber}(In:end),1); %Perform linear regression
        RegLine{FileNumber}=polyval(Reg,Disp{FileNumber});
    end
end

function RegLinePlot=PlotRegressions(NewAx,RegLine,Disp)
   for FileNumber=1:length(RegLine)
       RegLinePlot(FileNumber)=plot(NewAx,Disp{FileNumber},RegLine{FileNumber},'b');
   end
end

function CloseFig(fig,editbox)
    pause('off')
    global DistIn
    DistIn=editbox.Value;
    %assignin('base','DistIn',editbox.Value)
    delete(fig)
end

function [lbl,editbox,slider,saveButton]=CreateComponents(fig)
    lbl=uilabel(fig,'Position',[90 20 100 22],'Text','Fraction to ignore:');
    editbox=uieditfield(fig,'numeric','Position',[190 20 50 22],...
        'Limits',[0 1],'LowerLimitInclusive','on', ...
        'UpperLimitInclusive','off','Value',0.3,...
        'ValueDisplayFormat','%.2f');
    slider=uislider(fig,'Position',[270 35 150 3],'Value',0.3,...
        'Limits',[0 1],'MinorTicks',[]);
    saveButton=uibutton(fig,'Position',[450 20 50 22],'Text','Save');
end