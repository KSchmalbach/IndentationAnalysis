function [ZeroedDisp,ZeroedLoad,NewMod,NewHard]=ZeroHLIndentLoadDisp(Disp,Load,Time,Stiff,ARAdir)
    arguments
        Disp cell
        Load cell
        Time cell
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
        for Point=1:length(Disp{FileNumber})
            %Find where the load-displacement goes flat during lift
            Reg=polyfit(Disp{FileNumber}(Point:Point+2),Load{FileNumber}(Point:Point+2),1);
            %Find where tip makes contact during reseek
            deltaP=Load{FileNumber}(Point+1)-Load{FileNumber}(Point);
            if Reg(1)>50 && Time{FileNumber}(Point)>2 && deltaP>100
                ZeroLoad=Load{FileNumber}(Point);
                ZeroDisp=Disp{FileNumber}(Point);
                break
            end
        end
        %Rezero load and displacment
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