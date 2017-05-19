function varargout = ControlGUI1(varargin)
% CONTROLGUI1 MATLAB code for ControlGUI1.fig
%      CONTROLGUI1, by itself, creates a new CONTROLGUI1 or raises the existing
%      singleton*.
%
%      H = CONTROLGUI1 returns the handle to a new CONTROLGUI1 or the handle to
%      the existing singleton*.
%
%      CONTROLGUI1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONTROLGUI1.M with the given input arguments.
%
%      CONTROLGUI1('Property','Value',...) creates a new CONTROLGUI1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ControlGUI1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ControlGUI1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ControlGUI1

% Last Modified by GUIDE v2.5 31-Dec-2015 14:32:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ControlGUI1_OpeningFcn, ...
                   'gui_OutputFcn',  @ControlGUI1_OutputFcn, ...
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


% --- Executes just before ControlGUI1 is made visible.
function ControlGUI1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle11 to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ControlGUI1 (see VARARGIN)

% Choose default command line output for ControlGUI1
handles.output = hObject;
%initialize
delete(instrfind('Port','COM6'));
clear a;
global a; %need this line everywhere
a = arduino('COM6','Mega2560');

% choose airfoil number
handles.foilNumber = 1;
handles.index=1;
ChooseAirfoil;

Display_Properties(handles);
handles.temperatureVal = 22;
handles.pressureVal=0;

handles.tempSensorPin = 'A8';
handles.pressureSensorPin = 'A9';
handles.sevenSegSensorPin = [25 22 23 24];s
% int A = 25; // 7
% int B = 22; // 1
% int C = 23; // 2s
% int D = 24; // 6

% data table
handles.data = zeros(6,2);

Realtime_Display(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ControlGUI1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ControlGUI1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in foilNum.
function foilNum_Callback(hObject, eventdata, handles)
% hObject    handle to foilNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get wave number
x = get(hObject,'Value');
handles.index=x;
% Set selected number to current number, and plot waves
handles.foilNumber=handles.index;
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
axes(hObject);
imshow('airfoil.png');

% Display wave properties, executes after initalization
function Display_Properties(handles)
    
%set(handles.SampleFrequency, 'String', strcat(num2str(handles.SampleRate/1e6), ' MHz'));  %Sampling Frequency

%Display choices for wave number popup menu
for i = 1:4
    options(i)=i; 
    i=i+1;
end
mat2str(num2str(options'));
set(handles.foilNum,'String',{options},'Value',1);

function Realtime_Display(hObject,handles)
global a;
set(handles.dataTable,'Data',handles.data);
Temperature_Update(hObject, handles);
Strain_Update(hObject, handles);
Velocity_Update(hObject,handles);
Digit_Update(hObject, handles);
guidata(hObject, handles);

function Temperature_Update(hObject, handles)
global a;
voltage = readVoltage(a,'A8');

handles.temperatureVal = (voltage - 0.5) * 100 ; 
set(handles.temperature, 'String', strcat(num2str(handles.temperatureVal), ' deg C'));  %Sampling Frequency

%Fahrenheit = (temperatureC * 9.0 / 5.0) + 32.0;
pause(0.01);                              

guidata(hObject,handles);

function Strain_Update(hObject,handles)
%
guidata(hObject,handles);

function Velocity_Update(hObject,handles)
global a;
voltage = readVoltage(a,'A9');
pressureDiff = (2.58-voltage)/0.25*2;
% 2.58 = 0
% air density = 1.225;
% deviate by .25
% -2 to 2 kpa
% air pressure 101.325 kpa
handles.velocityVal = sqrt(2*pressureDiff/1.225);
%set(handles.velocity, 'String', strcat(num2str(handles.velocityVal), ' m/s'));  %Sampling Frequency
pause(0.01);

% v = sqrt(2*diffpressure/airdensity)
guidata(hObject,handles);

function Digit_Update(hObject,handles)
global a;
%  configurePin(a,num2str(handles.sevenSegSensorPin(1)),'output');                  
 
 %0
 writeDigitalPin(a, handles.sevenSegSensorPin(1), 0); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 0); 
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
  pause(0.01);

 %1
writeDigitalPin(a, handles.sevenSegSensorPin(1), 1); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 0); 
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
  pause(0.01);
  
%2
writeDigitalPin(a, handles.sevenSegSensorPin(1), 0); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 1); 
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
  pause(0.01);
  
 %3
 writeDigitalPin(a, handles.sevenSegSensorPin(1), 1); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 1); 
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
  pause(0.01);
  
%4
writeDigitalPin(a, handles.sevenSegSensorPin(1), 0); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 0); 
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 1);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
  pause(0.01);
  
% %5
writeDigitalPin(a, handles.sevenSegSensorPin(1), 1); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 0); 
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 1);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
  pause(0.01);
  
%6
  writeDigitalPin(a, handles.sevenSegSensorPin(1), 0); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 1);
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 1);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
   pause(0.01);
  
 %7
   writeDigitalPin(a, handles.sevenSegSensorPin(1), 1); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 1);
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 1);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 0); 
  pause(0.01);
  
%8
   writeDigitalPin(a, handles.sevenSegSensorPin(1), 0); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 0);
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 1); 
  pause(0.01);
  
%9
  writeDigitalPin(a, handles.sevenSegSensorPin(1), 1); 
  writeDigitalPin(a, handles.sevenSegSensorPin(2), 0);
   writeDigitalPin(a, handles.sevenSegSensorPin(3), 0);
    writeDigitalPin(a, handles.sevenSegSensorPin(4), 1); 
  pause(0.01);
guidata(hObject,handles);


% Hint: place code in OpeningFcn to populate foilDiagram
