function varargout = ChooseAirfoil(varargin)
% CHOOSEAIRFOIL MATLAB code for ChooseAirfoil.fig
%      CHOOSEAIRFOIL, by itself, creates a new CHOOSEAIRFOIL or raises the existing
%      singleton*.
%
%      H = CHOOSEAIRFOIL returns the handle to a new CHOOSEAIRFOIL or the handle to
%      the existing singleton*.
%
%      CHOOSEAIRFOIL('CALLBACK',hObject1,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSEAIRFOIL.M with the given input arguments.
%
%      CHOOSEAIRFOIL('Property','Value',...) creates a new CHOOSEAIRFOIL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseAirfoil_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseAirfoil_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseAirfoil

% Last Modified by GUIDE v2.5 02-Jan-2016 16:37:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseAirfoil_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseAirfoil_OutputFcn, ...
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


% --- Executes just before ChooseAirfoil is made visible.
function ChooseAirfoil_OpeningFcn(hObject1, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject1    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseAirfoil (see VARARGIN)

% Choose default command line output for ChooseAirfoil
handles.output= hObject1;

%Display choices for foil number popup menu
for i = 1:4
    options(i)=i; 
end
mat2str(num2str(options'));
set(handles.chooseAirfoil,'String',{options},'Value',1);

% set initial image
axes(handles.foilPic);
imshow('foil1.jpg');
handles.index=1;

handles.okPushed=1;
setappdata(handles.gui1,'index',handles.index);

% Update handles structure
guidata(hObject1, handles);

% UIWAIT makes ChooseAirfoil wait for user response (see UIRESUME)
% uiwait(handles.gui1);


% --- Outputs from this function are returned to the command line.
function varargout = ChooseAirfoil_OutputFcn(hObject1, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject1    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in chooseAirfoil.
function chooseAirfoil_Callback(hObject1, eventdata, handles)
% hObject1    handle to chooseAirfoil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get wave number
x = get(hObject1,'Value');
handles.index=x;
%set(handles.chooseAirfoil,'String',num2str(x),'Value',x);
axes(handles.foilPic);

if x==1
    imshow('foil1.jpg');
else
    if x==2
        imshow('foil2.jpg');
    else
        if x==3
            imshow('foil3.jpg');           
        else
            if x==4
                imshow('foil4.jpg');
            end
        end
    end
end
            
guidata(hObject1, handles);

function chooseAirfoil_CreateFcn(hObject1,eventdata,handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject1,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject1,'BackgroundColor','white');
end
% Hints: contents = cellstr(get(hObject1,'String')) returns chooseAirfoil contents as cell array
%        contents{get(hObject1,'Value')} returns selected item from chooseAirfoil


% --- Executes on button press in ok.
function ok_Callback(hObject1, eventdata, handles)
% hObject1    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.okPushed = 0;
setappdata(handles.gui1,'index',handles.index);
guidata(hObject1,handles);
set(handles.gui1,'Visible','off');
%close(handles.output);

%guidata(hObject1,handles);
