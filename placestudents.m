function [studentsunplaced,newareas,areas] = placestudents(areas,newareas)
    global students;
    
    % start each area with no students
    for i = 1:numel(areas)
        areas(i).students = 0;
        areas(i).studentswequalmatch2 = 0;
        areas(i).studentstotalk = 0;
        areas(i).studentswantingtotalk = 0;
        areas(i).studentstoposter=0;
    end
    
    for i=1:numel(students)
        newarea = 1;
        for j=1:numel(areas)
            if strcmp(students(i).area1,areas(j).name);
                students(i).areachoice=areas(j).name;
                areas(j).students=areas(j).students+1;
                if students(i).strengtharea1 == students(i).strengtharea2
                    areas(j).studentswequalmatch2 = areas(j).studentswequalmatch2 + 1;
                end
                newarea=0;
            end
        end
        if newarea == 1            
            if isempty(structfind(newareas,'name',students(i).area1))
                newareas(numel(newareas)+1).name = students(i).area1;
                newareas(end).students = 1;
            else
                newareas(structfind(newareas,'name',students(i).area1)).students = ...
                    newareas(structfind(newareas,'name',students(i).area1)).students +1;
            end
        end
    end
    
    %% Remove the empty newarea
    indices=[];
    for j=1:numel(newareas)
        if ~isempty(newareas(j).name)
            indices=[indices j];
        end
    end
    newareas = newareas(indices);
    
    studentsunplaced=sum(arrayfun(@(x) isempty(x.areachoice),students));
end