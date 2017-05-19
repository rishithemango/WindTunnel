% tags: airVelocity, temperature, lift, drag,foilNum, selectFoil, angle,
% selectAngle
% 58,2,60
% fatter side angles: 30,
function varargout = ControlGUI(varargin)
% ControlGUI MATLAB code for ControlGUI.fig
%      ControlGUI, by itself, creates a new ControlGUI or raises the existing
%      singleton*.
%
%      H = ControlGUI returns the handle to a new ControlGUI or the handle to
%      the existing singleton*.
%
%      ControlGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ControlGUI.M with the given input arguments.
%
%      ControlGUI('Property','Value',...) creates a new ControlGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ControlGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ControlGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ControlGUI

% Last Modified by GUIDE v2.5 06-Jan-2016 17:24:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ControlGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ControlGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ControlGUI is made visible.
function ControlGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle11 to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ControlGUI (see VARARGIN)

% Choose default command line output for ControlGUI
handles.output = hObject;
%initialize
delete(instrfind('Port','COM6'));
clear a;
global a; %need this line everywhere
a = arduino('COM6','Mega2560');

% choose airfoil number
handles.foilNumber = 1;
handles.index=1;
handles.ok=1;
ChooseAirfoil;
f = findobj('Tag','gui1');
waitfor(f,'Visible','off');
handles.index=getappdata(f,'index');
% handles.ok=getappdata(handles.figure1,'okPushed');
% while handles.ok~=0
% pause(0.5);
% handles.ok=getappdata(handles.figure1,'okPushed');
% end
% display airfoil
x = handles.index;
axes(handles.foilDiagram);
global I;
if x==1
    I = imread('foil1.jpg');
    imshow(I);
else
    if x==2
        I = imread('foil2.jpg');
        imshow(I);
    else
        if x==3
            I = imread('foil3.jpg');
            imshow(I);
        else
            if x==4
                I = imread('foil4.jpg');
                imshow(I);
            end
        end
    end
end

Display_Properties(hObject, handles);
handles.temperatureVal = 22;
handles.pressureVal=0;
handles.velocityVal=0;
handles.liftVal = 0;
handles.dragVal = 0;
handles.angleVal = 0;

handles.tempSensorPin = 'A8';
handles.pressureSensorPin = 'A9';
handles.sevenSegSensorPin = ...
    [37 34 35 36;...
    41 38 39 40;...
    49 46 47 48;...
    53 50 51 52];
% int A = 25; // 7 - white
% int B = 22; // 1 - yellow
% int C = 23; // 2 - green
% int D = 24; // 6 - orange

% data table
handles.data = zeros(6,2);
handles.angleliftData = zeros(0,0);
global calibrateTime;
global initialData;
global initialVel;
calibrateTime=0;
initialData = zeros(6,2);
initialVel=0;
% column 1 = lift, 2 = drag
handles.doneCalibrating=1;

Realtime_Display(hObject,handles);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ControlGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ControlGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Display wave properties, executes after initalization
function Display_Properties(hObject,handles)
    
%set(handles.SampleFrequency, 'String', strcat(num2str(handles.SampleRate/1e6), ' MHz'));  %Sampling Frequency

%Display choices for foil number popup menu
for i = 1:4
    options(i)=i; 
    i=i+1;
end
mat2str(num2str(options'));
set(handles.foilNum,'String',{options},'Value',handles.index);

%Display choices for angle popup menu
optionsa(1)=2;
optionsa(2)=30;
optionsa(3)=58;
optionsa(4)=60;
   
mat2str(num2str(optionsa'));
set(handles.angle,'String',{optionsa},'Value',1);
guidata(hObject,handles);

function Realtime_Display(hObject,handles)
pause(0.01);
while 1<5
% update data
calibrating = get(handles.calibrate,'Value');
if calibrating==1
    
    waitfor(handles.doneCalibrating,'Value',0);
    set(handles.calibrate,'String','Calibrate','enable','on','Value',0);
end
Temperature_Update(hObject, handles);
Strain_Update(hObject, handles);
Velocity_Update(hObject,handles);
%Digit_Update(hObject, handles);
pause(0.3);
end
guidata(hObject, handles);

% --- Executes on selection change in foilNum.
function foilNum_Callback(hObject, eventdata, handles)
% hObject    handle to foilNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get foil number
x = get(hObject,'Value');
handles.index=x;
% Set selected number to current number, and plot waves
handles.foilNumber=handles.index;
angle=get(handles.angle,'Value');
if angle==1
    handles.angleVal=-2;
else
    if angle==2
        handles.angleVal=-30;
    else
        if angle==3
            handles.angleVal=-58;
        else
            if angle==4
                handles.angleVal=-60;
            end
        end
    end
end

global I;
if x==1
    I = imread('foil1.jpg');
    imshow(I);
else
    if x==2
        I = imread('foil2.jpg');
        imshow(I);
    else
        if x==3
            I = imread('foil3.jpg');
            imshow(I);
        else
            if x==4
                I = imread('foil4.jpg');
                imshow(I);
            end
        end
    end
end
newI = imrotate(I,handles.angleVal);
%cla(handles.foilDiagram);
axes(handles.foilDiagram);
imshow(newI);
cla(handles.angleLiftPlot);

guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns foilNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from foilNum


% --- Executes during object creation, after setting all properties.
function foilNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to foilNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function foilDiagram_CreateFcn(hObject, eventdata, handles)
% hObject    handle to foilDiagram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% display airfoil
handles.index=x;
axes(handles.foilDiagram);
global I;
if x==1
    I = imread('foil1.jpg');
    imshow(I);
else
    if x==2
        I = imread('foil2.jpg');
        imshow(I);
    else
        if x==3
            I = imread('foil3.jpg');
            imshow(I);
        else
            if x==4
                I = imread('foil4.jpg');
                imshow(I);
            end
        end
    end
end
newI = imrotate(I,handles.angleVal);
axes(handles.foilDiagram);
imshow(newI);
guidata(hObject,handles);


function Temperature_Update(hObject, handles)
global a;
voltage = readVoltage(a,handles.tempSensorPin);
handles.temperatureVal = (voltage - 0.5) * 100;
set(handles.temperature, 'String', strcat((num2str(handles.temperatureVal,'%.3f')), ' deg C'));  
%Fahrenheit = (temperatureC * 9.0 / 5.0) + 32.0;
guidata(hObject,handles);


function Strain_Update(hObject,handles)
handles.data = getStrain(hObject,handles);
global initialData;

% adjust with calibrated data
for i=1:6
    for j=1:2
        handles.data(i,j)=handles.data(i,j)-initialData(i,j);
    end
end

% calculate total lift + drag
handles.liftVal = -handles.data(4,1);%handles.data(1,1)-handles.data(2,1)+handles.data(3,1)-handles.data(4,1);
handles.dragVal = handles.data(5,2)*2;%handles.data(5,2)+handles.data(6,2);

% draw arrows
delete(findall(gcf,'Tag','liftArrow'));
delete(findall(gcf,'Tag','dragArrow'));
arrowlength1=handles.liftVal*0.6/10000;
arrowlength2=handles.dragVal*0.6/10000;
% need arrows to stay in range
if arrowlength1>=0.22
    arrowlength1=0.22;
end
if arrowlength2>=0.2
    arrowlength2=0.2;
end
if arrowlength1<=-0.22
    arrowlength1=-0.22;
end
if arrowlength2<=-0.2
    arrowlength2=-0.2;
end

% draw the arrows
x1 = [0.24 0.24];
y1 = [0.38  0.38+arrowlength1];
annotation('textarrow',x1,y1,'Tag','liftArrow','String','Lift','LineWidth',1,'Color','magenta');
x2 = [0.4  0.4+arrowlength2];
y2 = [0.3 0.3];
annotation('textarrow',x2,y2,'Tag','dragArrow','String','Drag','LineWidth',1,'Color','cyan');

% check if calibrate button is pressed
    set(handles.lift, 'String', strcat(num2str(handles.liftVal,'%.3f'), ' N'));
    set(handles.drag, 'String', strcat(num2str(handles.dragVal,'%.3f'), ' N'));
        set(handles.liftDragTable,'Data',handles.data);
guidata(hObject,handles);

function strainData = getStrain(hObject,handles)
global a;
% strain gauge calibration: 3.54, 7.1
% DRAG--------------------------------------------------
% #4  this one works
% 196.2, 204.667
drag1 = readVoltage(a,'A2');
aReading = 196.2*5/1023;
aLoad = 3.54*9.8; 
bReading = 204.667*5/1023;
bLoad = 7.1*9.8;
handles.data(5,2)= ((bLoad - aLoad)/(bReading - aReading)) * (drag1 - aReading) + aLoad;

% #3
% 181, 192.267
drag2 = readVoltage(a,'A7');
aReading = 181*5/1023;
aLoad = 3.54*9.8; 
bReading = 192.267*5/1023;
bLoad = 7.1*9.8;
handles.data(6,2)= ((bLoad - aLoad)/(bReading - aReading)) * (drag2 - aReading) + aLoad;

% LIFT----------------------------------------------------
% #5
% 171.375, 179.556
uplift1 = readVoltage(a,'A4');
aReading = 171.375*5/1023;
aLoad = 3.54*9.8; 
bReading = 179.556*5/1023;
bLoad = 7.1*9.8;
handles.data(1,1)= ((bLoad - aLoad)/(bReading - aReading)) * (uplift1- aReading) + aLoad;

% #6
% 184.278, 192.923
downlift1 = readVoltage(a,'A3');
aReading = 184.278*5/1023;
aLoad = 3.54*9.8; 
bReading = 192.923*5/1023;
bLoad = 7.1*9.8;
handles.data(2,1)= ((bLoad - aLoad)/(bReading - aReading)) * (downlift1 - aReading) + aLoad;

% #2
% 114.5882,118.5455
uplift2 = readVoltage(a,'A5');
aReading = 114.5882*5/1023;
aLoad = 3.54*9.8; 
bReading = 118.5455*5/1023;
bLoad = 7.1*9.8;
handles.data(3,1)= ((bLoad - aLoad)/(bReading - aReading)) * (uplift2 - aReading) + aLoad;
% #8  this one works
% 158.5, 163.1304
downlift2 = readVoltage(a,'A6');
aReading = 158.5*5/1023;
aLoad = 3.54*9.8; 
bReading = 163.1304*5/1023;
bLoad = 7.1*9.8;
handles.data(4,1)= ((bLoad - aLoad)/(bReading - aReading)) * (downlift2 - aReading) + aLoad;

strainData = handles.data;
% % check if calibrate button is pressed
% handles.calibrate_ON = get(handles.calibrate,'Value');
% if handles.calibrate_ON==1
   
% end
guidata(hObject,handles);


function Velocity_Update(hObject,handles)
global initialVel;
handles.velocityVal = getVelocity(hObject,handles)-initialVel;
set(handles.airVelocity, 'String', strcat(num2str(handles.velocityVal,'%.3f'), ' m/s'));  
Digit_Update(hObject,handles);
guidata(hObject,handles);

function velocityData = getVelocity(hObject,handles)
global a;
% 2.58 = 0
% air density = 1.225;
% deviate by .25
% -2 to 2 kpa
% air pressure 101.325 kpa
voltage = readVoltage(a,handles.pressureSensorPin);
pressureDiff = (2.54154-voltage)*1000;
%pressureDiff = 5*(voltage*0.0048828/5-0.5);
% rise over run = -1 slope?
handles.velocityVal = sqrt(2*abs(pressureDiff)/1.225);
velocityData = handles.velocityVal;
guidata(hObject,handles);

function Digit_Update(hObject,handles)
global a;
%handles.velocityVal = getVelocity(hObject,handles);
%  configurePin(a,num2str(handles.sevenSegSensorPin(i,1)),'output'); 
% configure each digit
handles.velocityVal=round(handles.velocityVal,2);
tempvel = num2str(handles.velocityVal);
% for i=1:length(tempvel)
%     if (isempty(tempvel(i)))
%         tempvel(i)='0';
%     end
% end
if length(tempvel)<5
    tempvel=strcat(num2str(handles.velocityVal),'0','0');
end

digit = zeros(4);
if (handles.velocityVal>1 && handles.velocityVal<10)
    digit(1) = 0;
    digit(2) = str2num(tempvel(1));
    digit(3) = str2num(tempvel(3));
    digit(4) = str2num(tempvel(4));
else
    if (handles.velocityVal>10)
        digit(1) = str2num(tempvel(1));
        digit(2) = str2num(tempvel(2));
        digit(3) = str2num(tempvel(4));
        digit(4) = str2num(tempvel(5));
    else
        if (handles.velocityVal>0 && handles.velocityVal<1)
        digit(1) = 0;
        digit(2) = 0;
        digit(3) = str2num(tempvel(3));
        digit(4) = str2num(tempvel(4));
        else
            digit = zeros(4);
        end
    end
end

for i=1:4
if digit(i)==0
    %0
    writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
else
    if digit(i)==1
        %1
        writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 1);
        writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 0);
        writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 0);
        writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
    else
        if digit(i)==2
            %2
            writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 0);
            writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 1);
            writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 0);
            writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
        else
            if digit(i)==3
                %3
                writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 1);
                writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 1);
                writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 0);
                writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
            else
                if digit(i)==4
                    %4
                    writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 0);
                    writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 0);
                    writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 1);
                    writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
                else
                    if digit(i)==5
                        %5
                        writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 1);
                        writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 0);
                        writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 1);
                        writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
                    else
                        if digit(i)==6
                            %6
                            writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 0);
                            writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 1);
                            writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 1);
                            writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
                        else
                            if digit(i)==7
                                %7
                                writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 1);
                                writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 1);
                                writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 1);
                                writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 0);
                            else
                                if digit(i)==8
                                    %8
                                    writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 0);
                                    writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 0);
                                    writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 0);
                                    writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 1);
                                else
                                    if digit(i)==9
                                        %9
                                        writeDigitalPin(a, handles.sevenSegSensorPin(i,1), 1);
                                        writeDigitalPin(a, handles.sevenSegSensorPin(i,2), 0);
                                        writeDigitalPin(a, handles.sevenSegSensorPin(i,3), 0);
                                        writeDigitalPin(a, handles.sevenSegSensorPin(i,4), 1);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
end
    guidata(hObject,handles);


% --- Executes on selection change in angle.
function angle_Callback(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get foil number
x = get(hObject,'Value');
% Set selected number to current number, and plot waves
if x==1
handles.angleVal=-2;
else
    if x==2
        handles.angleVal=-30;
    else
        if x==3
            handles.angleVal=-58;
        else
            if x==4
                handles.angleVal=-60;
            end
        end
    end
end
global I;
newI = imrotate(I,handles.angleVal);
axes(handles.foilDiagram);
imshow(newI);
guidata(hObject, handles);


% Hints: contents = cellstr(get(hObject,'String')) returns angle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from angle


% --- Executes during object creation, after setting all properties.
function angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function calibrate_Callback(hObject, eventdata, handles)
global initialData;
global initialVel;
handles.doneCalibrating=1;    
initialData=zeros(6,2);
initialVel=0;

for i=1:5
handles.data=getStrain(hObject,handles);
handles.velocityVal=getVelocity(hObject,handles);
set(handles.calibrate,'String','Calibrating...','enable','off','Value',1);
set(handles.lift,'String','Calibrating...');
set(handles.drag,'String','Calibrating...');
set(handles.airVelocity,'String','Calibrating...');
    % calibrate for 5 seconds
    % store data points
    for i=1:6
        for j=1:2 
            initialData(i,j)=initialData(i,j)+handles.data(i,j);
        end
    end
    initialVel = initialVel+handles.velocityVal;
            set(handles.liftDragTable,'Data',zeros(6,2));
end
  
for i=1:6
    for j=1:2
        initialData(i,j)=initialData(i,j)./5;
    end
end
initialVel=initialVel/5;

handles.doneCalibrating=0;
    
guidata(hObject,handles);


% --- Executes on button press in addData.
function addData_Callback(hObject, eventdata, handles)
% hObject    handle to addData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold on;
% read lift + angle values 
laData = getLiftAngleData(hObject,handles);
% retrieve data points already on graph
data_handles = get(handles.angleLiftPlot,'children');
x = get(data_handles,'Xdata');
y = get(data_handles,'Ydata');

% add new data point to old data matrix
% check to see if plot was empty
if isempty(x)==0

% new matrix with new data point added on
handles.angleliftData = zeros(length(x)+1,2);
for i=1:length(x)
handles.angleliftData(i,1) = x(i);
handles.angleliftData(i,2) = y(i);
end
handles.angleliftData(length(x)+1,1)=laData(1);
handles.angleliftData(length(x)+1,2)=laData(2);
%if plot was empty
else
    handles.angleliftData=laData;
end

% plot new matrix
scatter(handles.angleLiftPlot,handles.angleliftData(:,1),handles.angleliftData(:,2),'o','MarkerEdgeColor','blue');
xlabel(handles.angleLiftPlot,'Angle (deg)','FontSize',8);
xlim(handles.angleLiftPlot,[0 65]);
ylabel(handles.angleLiftPlot,'Lift (N)','FontSize',8);
grid on;
guidata(hObject,handles);

function laData = getLiftAngleData(hObject,handles)
x=get(handles.angle,'Value');
if x==1
handles.angleVal=2;
else
    if x==2
        handles.angleVal=30;
    else
        if x==3
            handles.angleVal=58;
        else
            if x==4
                handles.angleVal=60;
            end
        end
    end
end
liftString=get(handles.lift,'String');
handles.liftVal=sscanf(liftString,'%f');
% increase array dimension
% handles.angleliftData = [handles.angleliftData;0 0];
laData = [handles.angleVal,handles.liftVal];
guidata(hObject,handles);


% --- Executes on button press in resetData.
function resetData_Callback(hObject, eventdata, handles)
% hObject    handle to resetData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.angleliftData=zeros(0,0);
cla(handles.angleLiftPlot);
guidata(hObject,handles);
