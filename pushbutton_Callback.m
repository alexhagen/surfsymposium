function pushbutton_Callback(hObject,eventdata)
    s=get(hObject,'UserData');
    studentno=s.studentno;
	global students;
    startpos=s.startpos;
    stoppos=s.stoppos;
    h1=s.h1;
    h=s.h;
    a=s.a;
    ui=s.ui;
    % switch student's choice to second choice
    students(studentno).areachoice = students(studentno).area2;
    y=get(h1,'YData');
    y2=get(h,'YData');
    y(startpos)=y(startpos)-1;
    y2(stoppos)=y2(stoppos)+1;
    y(stoppos)=y(stoppos)+1;
    set(h1,'YData',y);
    set(h,'YData',y2);
    delete(a);
    delete(ui);

end