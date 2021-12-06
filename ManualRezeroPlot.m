function [ZeroDisp,ZeroLoad]=ManualRezeroPlot(Disp,Load,Filenum)
    
    arguments
        Disp double
        Load double
        Filenum double
    end
    global ZeroDisp
    global ZeroLoad
    
    set(0,'defaultAxesFontSize',12)
    fig=uifigure('Name',strcat("File ",string(Filenum)),'Resize','off');
    [~,~,LoadEbox,DispEbox,saveButton,NewAx]=CreateComponents(fig);
    xlabel(NewAx,'Displacement (nm)')
    ylabel(NewAx,'Load (\muN)')
    hold(NewAx,'on')
    plot(NewAx,Disp,Load,'k.')
    xlim(NewAx,[-50 50])
    saveButton.ButtonPushedFcn=@(but,event) SaveButtonPressed(but,fig,LoadEbox.Value,DispEbox.Value);
    
    
    fig.CloseRequestFcn=@(~,event) CloseFig(fig,LoadEbox.Value,DispEbox.Value);
    uiwait(fig)
end

function SaveButtonPressed(but,fig,LoadVal,DispVal)
    pause('off') 
    global ZeroDisp
    global ZeroLoad
    ZeroDisp=DispVal;
    ZeroLoad=LoadVal;
    %format='Load changed to %4.2f and disp changed to %4.2f';
    %fprintf(format,LoadVal,DispVal);
    delete(fig) 
end
function CloseFig(fig,LoadVal,DispVal)
    pause('off')
    global ZeroDisp
    global ZeroLoad
    ZeroDisp=DispVal;
    ZeroLoad=LoadVal;
    delete(fig)
end
function [LoadLbl,DispLbl,LoadEbox,DispEbox,saveButton,NewAx]=CreateComponents(fig)
    LoadLbl=uilabel(fig,'Position',[260 20 100 22],'Text','Load:');
    DispLbl=uilabel(fig,'Position',[90 20 100 22],'Text','Displacement:');
    DispEbox=uieditfield(fig,'numeric','Position',[170 20 55 22],...
        'ValueDisplayFormat','%8.2f');
    LoadEbox=uieditfield(fig,'numeric','Position',[300 20 55 22],...
        'ValueDisplayFormat','%8.2f');
    saveButton=uibutton(fig,'Position',[450 20 50 22],'Text','Save');
    NewAx=axes(fig,'Position',[0.11 0.22 0.775 0.715]);
end