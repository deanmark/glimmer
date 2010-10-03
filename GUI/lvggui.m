function varargout = LVGGUI(varargin)
% LVGGUI M-file for LVGGUI.fig
%      LVGGUI, by itself, creates a new LVGGUI or raises the existing
%      singleton*.
%
%      H = LVGGUI returns the handle to a new LVGGUI or the handle to
%      the existing singleton*.
%
%      LVGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LVGGUI.M with the given input arguments.
%
%      LVGGUI('Property','Value',...) creates a new LVGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LVGGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LVGGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LVGGUI

% Last Modified by GUIDE v2.5 21-Sep-2010 12:11:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LVGGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LVGGUI_OutputFcn, ...
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


% --- Executes just before LVGGUI is made visible.
function LVGGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LVGGUI (see VARARGIN)

% Choose default command line output for LVGGUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LVGGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function CallCreateFunction(hObject, handles)

CreateFcn = get(hObject,'CreateFcn');
[a1] = CreateFcn(hObject, []);
'tst';

% --- Outputs from this function are returned to the command line.
function varargout = LVGGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiopen('load');

% --------------------------------------------------------------------
function SaveAsMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uisave();

% --------------------------------------------------------------------
function ExitMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ExitMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg('Do you want to close the GUI?',...
                     'Close Request Function',...
                     'Yes','No','Yes');
switch selection,
   case 'Yes',
    delete(gcf)
   case 'No'
     return
end

% --------------------------------------------------------------------
function DownloadMoldataMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to DownloadMoldataMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt={'Enter Lamda main website:'};
name='Input for download function';
numlines=1;
defaultanswer={'http://www.strw.leidenuniv.nl/~moldata/'};
options.Resize='on';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);
downloadAllLamdaDataFiles (answer);


% --------------------------------------------------------------------
function LoadMoldataMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMoldataMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadAllMoleculesLamdaFormat();

function TabPlaceHolder_Callback(hObject, eventdata, handles)
% hObject    handle to TabPlaceHolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TabPlaceHolder as text
%        str2double(get(hObject,'String')) returns contents of TabPlaceHolder as a double


% --- Executes during object creation, after setting all properties.
function TabPlaceHolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TabPlaceHolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
