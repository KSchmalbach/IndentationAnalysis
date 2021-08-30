function CutData=CutBefore(DataToCut,BasisData,Condition)
    arguments
        DataToCut cell
        BasisData cell
        Condition double
    end
    nfiles=length(DataToCut);
    CutData=cell(nfiles,1);
    for FileNumber=1:nfiles
        BreakPoint=0;
        %Very slow: should use actual search function to find first point
        %that satisfies
        %{
        for Point=length(DataToCut{FileNumber}):-1:1
            %Find place in data where the basis data is below criterion
            if BasisData{FileNumber}(Point,1)<Condition
                BreakPoint=Point;
                break
            end
        end
        %}
        BreakPoint=find(BasisData{FileNumber}<Condition,1,'last');
        %If a breakpoint is found, cut
        if BreakPoint ~= 0
            CutData{FileNumber}=DataToCut{FileNumber}(BreakPoint:end);
            %CutData{FileNumber}=DataToCut{FileNumber}(BreakPoint+1:end);
        else
            %If no breakpoint, assign to input data
            CutData{FileNumber}=DataToCut{FileNumber};
        end
    end
end