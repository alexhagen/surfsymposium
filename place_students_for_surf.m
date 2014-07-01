function place_students_for_surf(talksessions,talkspersession)
clear; close all; clc;
global students;
%% Initialize variables.
filename = 'Audit_Results.csv';
delimiter = ',';
startRow = 3;
formatSpec = '%s%s%f%s%f%s%f%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
Name = dataArray{:, 1};
GA = dataArray{:, 2};
OralPoster = dataArray{:, 3};
Area1 = dataArray{:, 4};
StrengthArea1 = dataArray{:, 5};
Area2 = dataArray{:, 6};
StrengthArea2 = dataArray{:, 7};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

% convert this imported array into student structures, allowing for object
% oriented type programming
students = struct();
for i = 1:numel(Name)
    students(i).name=Name{i};
    students(i).ga=GA{i};
    students(i).oralposter=OralPoster(i);
    students(i).preschoice=[];
    students(i).area1=strrep(Area1{i},' ','_');
    students(i).strengtharea1=StrengthArea1(i);
    students(i).area2=strrep(Area2{i},' ','_');
    students(i).strengtharea2=StrengthArea2(i);
    students(i).areachoice=[];
end

% make a list of areas
areas = struct();
areas(1).name = 'Energy';
areas(2).name = 'Materials';
areas(3).name = 'Health';
areas(4).name = 'Water';
areas(5).name = 'Infrastructure';
areas(6).name = 'Sustainability';
areas(7).name = 'Sensing';
areas(8).name = 'Biotechnology';
areas(9).name = 'Nanotechnology';
areas(10).name = 'Earth_and_Space_Sciences';
areas(11).name = 'Transportation';
areas(12).name = 'Simulation';

% make a structure for possibly added new areas
newareas = struct();

%% Make new categories for students who definitely need it
studentsunplaced=sum(arrayfun(@(x) isempty(x.areachoice),students));
while studentsunplaced>0
    [~,newareas,areas] = placestudents(areas,newareas);
    
    %% Try to decide if we can add a new category
    for j = 1:numel(newareas)
        match2=0;
        match1=0;
        match0=0;
        for i = 1:numel(students)
            if strcmp(students(i).area1,newareas(j).name)
                switch students(i).strengtharea2
                    case 0
                        match0=match0+1;
                    case 1
                        match1=match1+1;
                    case 2
                        match2=match2+1;
                    otherwise
                        neverreach=1;
                end
            end
        end
        question=sprintf(['If I were to add a new area called "%s" to ' ...
            'the possibilities, I could take place %d students.  If I ' ...
            'were to place those students with their second choice, ' ...
            'there are %d that have a good second category, %d that have ' ...
            'a mediocre second category, and %d that have a poor second ' ...
            'category.  Should I add the category?'], ...
            newareas(j).name,newareas(j).students,match2,match1,match0);
        button = questdlg(question);
        if strcmp('Yes',button)
            newareas(j).studentswequalmatch2 = 0;
            newareas(j).studentstotalk = 0;
            newareas(j).studentswantingtotalk = 0;
            newareas(j).studentstoposter=0;
            areas(end+1)=newareas(j);
        elseif strcmp('No',button)
            for i = 1:numel(students)
                if strcmp(students(i).area1,newareas(j).name)
                    students(i).areachoice=students(i).area2;
                    for k=1:numel(areas)
                        if strcmp(students(i).areachoice,areas(k).name)
                            areas(k).students=areas(k).students+1;
                        end
                    end
                end
            end
        end
    end
    
    [studentsunplaced,newareas,areas] = placestudents(areas,newareas);
end

%% make a second students array for if we chose their second choice


h1=bar(arrayfun(@(x) x.students,areas));
hold on;
h=bar(arrayfun(@(x) x.students-x.studentswequalmatch2,areas),'FaceColor','r');
set(gca,'XTickLabel',arrayfun(@(x) x.name,areas,'UniformOutput',0));
set(gcf, 'Position', [0 50 1920 600])

[h,ax,choices] = showequalmoves(h1,h,gca);

waitfor(gcf);

[studentsunplaced,newareas,areas] = placestudents(areas,newareas);

%% Determine which tracks can have talks

for i=1:numel(students)
    for j=1:numel(areas)
        if strcmp(areas(j).name,students(i).areachoice)
            if students(i).oralposter < 2
                areas(j).studentswantingtotalk=areas(j).studentswantingtotalk+1;
            end
        end
    end
end

talksessionsleft = talksessions;

for j=1:numel(areas)
    if areas(j).studentswantingtotalk >= talkspersession && talksessionsleft > 0
        areas(j).talk=1;
        areas(j).talksleft=3;
        talksessionsleft = talksessionsleft - 1;
    else
        areas(j).talk=0;
        areas(j).talksleft=0;
    end
end

r=randperm(numel(students));

for i=randperm(numel(students))
    for j=1:numel(areas)
        if strcmp(areas(j).name,students(i).areachoice)
            if areas(j).talksleft > 0 && students(i).oralposter <= 2
                areas(j).talksleft=areas(j).talksleft-1;
                areas(j).studentstotalk=areas(j).studentstotalk+1;
                students(i).preschoice='oral';
            else
                areas(j).studentstoposter=areas(j).studentstoposter+1;
                students(i).preschoice='poster';
            end
        end
    end
end


strucdisp(students,-1,1,200,'studentwiseoutput.txt');

strucdisp(areas,-1,1,100,'sectionwiseoutput.txt');
end