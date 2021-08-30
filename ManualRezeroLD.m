function [ZeroedDisp,ZeroedLoad,NewMod,NewHard]=ManualRezeroLD(Disp,Load,Stiff,ARAdir)
    arguments
        Disp cell
        Load cell
        Stiff cell
        ARAdir char
    end
    nfiles=length(Disp);
    ZeroedLoad=cell(nfiles,1);
    ZeroedDisp=cell(nfiles,1);
    NewMod=cell(nfiles,1);
    NewHard=cell(nfiles,1);
    Coeffs=ReadARA(ARAdir);
    for FileNumber=1:nfiles
        [ZeroDisp,ZeroLoad]=ManualRezeroPlot(Disp{FileNumber},Load{FileNumber},FileNumber);
        ZeroedLoad{FileNumber}=Load{FileNumber}-ZeroLoad;
        ZeroedDisp{FileNumber}=Disp{FileNumber}-ZeroDisp;
        %Recalculate the contact depth based on stiffness
        eps=0.75;
        ContactDepth=ZeroedDisp{FileNumber}-eps*ZeroedLoad{FileNumber}./Stiff{FileNumber};
        %Use area function to calculate new contact area
        NewArea=Area(Coeffs,ContactDepth);
        %Use new contact area to calculate corrected modulus and hardness
        NewMod{FileNumber}=sqrt(pi)/2.*Stiff{FileNumber}*1e3./sqrt(NewArea); %Natively in TPa
        NewHard{FileNumber}=ZeroedLoad{FileNumber}*1e3./NewArea; %Natively in TPa
    end
end


function Ac=Area(Coeffs,hc)
    Ac=(Coeffs(1).*hc.^2+Coeffs(2).*hc+Coeffs(3).*hc.^(1/2)+Coeffs(4).*hc.^(1/4)+Coeffs(5).*hc.^(1/8)+Coeffs(6).*hc.^(1/16));
end