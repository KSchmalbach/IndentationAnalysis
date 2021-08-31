function [hc,H,Ac]=PlasErrCorr(ARAdir,Disp,Load,Er)
    arguments
        ARAdir char
        Disp cell
        Load cell
        Er double 
    end


Coeffs=ReadARA(ARAdir);
nfiles=length(Disp);

%Perfect Berk
m0=24.5;
beta=1;
eps=0.726;

Ac=cell(nfiles,1);
hc=cell(nfiles,1);
H=cell(nfiles,1);

for FileNumber=1:nfiles
    for Point=1:length(Load{FileNumber})
        Qm4=pi()*eps^2*(Load{FileNumber}(Point)*1e-6)^2/(4*beta^2*(Er*1e9)^2);
        Qnm4=Qm4*1e36;
        quot=4*sqrt(Qnm4);
        %analytic=0.5*(Disp(Point,FileNumber)+sqrt(Disp(Point,FileNumber)^2-quot));
        hc{FileNumber}(Point)=Disp{FileNumber}(Point)-20;
        f=AreaFunction(hc{FileNumber}(Point),Disp{FileNumber}(Point),Qnm4,Coeffs);
        diffstep=1;
        fpstep=AreaFunction(hc{FileNumber}(Point)+diffstep,Disp{FileNumber}(Point),Qnm4,Coeffs);
        fmstep=AreaFunction(hc{FileNumber}(Point)-diffstep,Disp{FileNumber}(Point),Qnm4,Coeffs);
        fprime=(fpstep-f)/(diffstep);
        Step=f/fprime;
        iter(Point)=1;
        hc{FileNumber}(Point)=hc{FileNumber}(Point)-Step;

        while abs(f)>1e1
            hc{FileNumber}(Point)=hc{FileNumber}(Point)-Step;
            f=AreaFunction(hc{FileNumber}(Point),Disp{FileNumber}(Point),Qnm4,Coeffs);
            fpstep=AreaFunction(hc{FileNumber}(Point)+diffstep,Disp{FileNumber}(Point),Qnm4,Coeffs);
            fmstep=AreaFunction(hc{FileNumber}(Point)-diffstep,Disp{FileNumber}(Point),Qnm4,Coeffs);
            fprime=(fpstep-fmstep)/(2*diffstep);
            Step=f/fprime;
            iter(Point)=iter(Point)+1;
            if iter(Point)>100
                break
            end
        end
        Ac{FileNumber}(Point)=Area(Coeffs,hc{FileNumber}(Point)); %nm^2
        H{FileNumber}(Point)=(Load{FileNumber}(Point)*1e-6)/(Ac{FileNumber}(Point)*1e-9);
        
    end
end



end

function f=AreaFunction(hc,disp,Q,Coeffs)
    f=(Coeffs(1)*hc^2+Coeffs(2)*hc+Coeffs(3)*hc^(1/2)+Coeffs(4)*hc^(1/4)+Coeffs(5)*hc^(1/8)+Coeffs(6)*hc^(1/16))*(disp-hc)^2-Q;
end
function Ac=Area(Coeffs,hc)
    Ac=(Coeffs(1)*hc^2+Coeffs(2)*hc+Coeffs(3)*hc^(1/2)+Coeffs(4)*hc^(1/4)+Coeffs(5)*hc^(1/8)+Coeffs(6)*hc^(1/16));
end
