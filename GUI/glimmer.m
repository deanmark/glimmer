%{
GLIMMER is a visual LVG (Large Velocity Gradient) analysis tool.

Copyright (C) 2012  Dean Mark <deanmark at gmail>, 
		Prof. Amiel Sternberg <amiel at wise.tau.ac.il>, 
		Department of Astrophysics, Tel-Aviv University

Documentation for the program is posted at http://deanmark.github.com/glimmer/

This file is part of GLIMMER.

GLIMMER is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GLIMMER is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}

function varargout = glimmer(varargin)
% glimmer M-file for glimmer.fig
%      glimmer, by itself, creates a new glimmer or raises the existing
%      singleton*.
%
%      H = glimmer returns the handle to a new glimmer or the handle to
%      the existing singleton*.
%
%      glimmer('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in glimmer.M with the given input arguments.
%
%      glimmer('Property','Value',...) creates a new glimmer or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before glimmer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to glimmer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help glimmer

% Last Modified by GUIDE v2.5 11-Oct-2012 21:50:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @glimmer_OpeningFcn, ...
                   'gui_OutputFcn',  @glimmer_OutputFcn, ...
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


% --- Executes just before glimmer is made visible.
function glimmer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to glimmer (see VARARGIN)

% Choose default command line output for glimmer
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes glimmer wait for user response (see UIRESUME)
% uiwait(handles.lvgMainFigure);

% --- Outputs from this function are returned to the command line.
function varargout = glimmer_OutputFcn(hObject, eventdata, handles) 
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

if ~isempty(who(WorkspaceHelper.MoleculesVariableName))
    eval(sprintf('assignin(''base'', WorkspaceHelper.MoleculesVariableName, %s);', WorkspaceHelper.MoleculesVariableName));
end
if ~isempty(who(WorkspaceHelper.ResultsVariableName))
    eval(sprintf('assignin(''base'', WorkspaceHelper.ResultsVariableName, %s);', WorkspaceHelper.ResultsVariableName));
end
if ~isempty(who(WorkspaceHelper.RequestsVariableName))
    eval(sprintf('assignin(''base'', WorkspaceHelper.RequestsVariableName, %s);', WorkspaceHelper.RequestsVariableName));
end

% --------------------------------------------------------------------
function SaveAsMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Please choose variables to save:', ...
	'Save As...', 'Molecules','Requests & Results','Cancel','Cancel');
% Handle response
switch choice
    case 'Molecules'
        eval([WorkspaceHelper.MoleculesVariableName '= WorkspaceHelper.GetMoleculesHashFromWorkspace();']);        
        uisave({WorkspaceHelper.MoleculesVariableName}, WorkspaceHelper.MoleculesVariableName);
    case 'Requests & Results'
        eval([WorkspaceHelper.ResultsVariableName '= WorkspaceHelper.GetLVGResultsHashFromWorkspace();']);    
        eval([WorkspaceHelper.RequestsVariableName '= WorkspaceHelper.GetLVGRequestsListFromWorkspace();']);  
        uisave({WorkspaceHelper.ResultsVariableName, WorkspaceHelper.RequestsVariableName});
end

% --------------------------------------------------------------------
function ExitMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ExitMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg('Do you want to close the GUI?',...
                     'Close',...
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
if ~isempty(answer)
    DownloadAllLamdaDataFiles (answer);
end


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


% --- Executes on button press in calculateButton.
function calculateButton_Callback(hObject, eventdata, handles)
% hObject    handle to calculateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ProcessRequests;


% --- Executes during object creation, after setting all properties.
function glimmer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to glimmer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

mol = WorkspaceHelper.GetMoleculesHashFromWorkspace();
if (mol.IsEmpty)
    
    %check if Molecules file exists
    fid = fopen(FileIOHelper.StandardMoleculeFilePath);
    if fid ~= -1
        fclose(fid);
        
        load(FileIOHelper.StandardMoleculeFilePath);
        
        if ~isempty(who(WorkspaceHelper.MoleculesVariableName))
            eval(sprintf('assignin(''base'', WorkspaceHelper.MoleculesVariableName, %s);', WorkspaceHelper.MoleculesVariableName));
        end
        
    end
    
end
% --- Executes on button press in ratiosButton.
function ratiosButton_Callback(hObject, eventdata, handles)
% hObject    handle to ratiosButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DisplayRatios;
