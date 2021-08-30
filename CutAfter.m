function CutData=CutAfter(DataToCut,BasisData,Condition)
    arguments
        DataToCut cell
        BasisData cell
        Condition double
    end
    nfiles=length(DataToCut);
    CutData=cell(nfiles,1);
    for FileNumber=1:nfiles
        BreakPoint=0;
        %Very slow: use actual search function for speed.
        %{
        for Point=1:length(DataToCut{FileNumber})
            if BasisData{FileNumber}(Point,1)>Condition
                BreakPoint=Point;
                break
            end
        end
        %}
        BreakPoint=find(BasisData{FileNumber}>Condition,1);
        if BreakPoint ~= 0
            CutData{FileNumber}=DataToCut{FileNumber}(1:BreakPoint);
            %CutData{FileNumber}=DataToCut{FileNumber}(1:BreakPoint-1);
        else
            CutData{FileNumber}=DataToCut{FileNumber};
        end
    end

end