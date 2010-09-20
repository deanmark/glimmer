function varargout = ProcessRequests(varargin)
% PROCESSREQUESTS M-file for ProcessRequests.fig
%      PROCESSREQUESTS, by itself, creates a new PROCESSREQUESTS or raises the existing
%      singleton*.
%
%      H = PROCESSREQUESTS returns the handle to a new PROCESSREQUESTS or the handle to
%      the existing singleton*.
%
%      PROCESSREQUESTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSREQUESTS.M with the given input arguments.
%
%      PROCESSREQUESTS('Property','Value',...) creates a new PROCESSREQUESTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProcessRequests_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProcessRequests_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProcessRequests

% Last Modified by GUIDE v2.5 20-Sep-2010 13:50:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProcessRequests_OpeningFcn, ...
                   'gui_OutputFcn',  @ProcessRequests_OutputFcn, ...
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


% --- Executes just before ProcessRequests is made visible.
function ProcessRequests_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProcessRequests (see VARARGIN)

% Choose default command line output for ProcessRequests
handles.output = hObject;
handles.ViewedRequestIndex = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProcessRequests wait for user response (see UIRESUME)
% uiwait(handles.processRequestsFigure);



% --- Outputs from this function are returned to the command line.
function varargout = ProcessRequests_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addButton.
function addButton_Callback(hObject, eventdata, handles)
% hObject    handle to addButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

requestStrings = get(handles.requestsListbox,'String');
newRequestString = genvarname('Request', requestStrings);

innerRequest = LVGSolverPopulationRequest.DefaultRequest();
innerRequest.RequestName = newRequestString;
guiReq = RequestPropertyGrid.ConvertRequestToGUIRequest(innerRequest);

RequestsListboxHelper.AddRequestToListBox(handles.requestsListbox,guiReq,handles.ViewedRequestIndex);



% --- Executes on button press in copyButton.
function copyButton_Callback(hObject, eventdata, handles)
% hObject    handle to copyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isempty(handles.ViewedRequestIndex))
    RequestsListboxHelper.DuplicateRequestInListBox(handles.requestsListbox, handles.ViewedRequestIndex);    
end


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname, filterindex] = uiputfile({'*.mat','MAT-files (*.mat)';'*.*',  'All Files (*.*)'});

if (~isequal(filename,0) && ~isequal(pathname,0) && ~isequal(filterindex,0))
    requests = get(handles.requestsListbox,'UserData');
    
    LVGRequests = RequestPropertyGrid.ConvertRequestToInternalRequest(requests);    
    save(fullfile(pathname,filename),'LVGRequests');    
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname, filterindex] = uigetfile({'*.mat','MAT-files (*.mat)';'*.*',  'All Files (*.*)'});

if (~isequal(filename,0) && ~isequal(pathname,0) && ~isequal(filterindex,0))
   
    S = load(fullfile(pathname,filename), '-mat');
    
    if isfield(S,'LVGRequests')
        internalRequests = S.LVGRequests;
        guiRequests = RequestPropertyGrid.ConvertRequestToGUIRequest(internalRequests);
        
        RequestPropertyGrid.ResetGripProperties(handles.requestPropertiesEditor);
        
        RequestsListboxHelper.SetRequestsToListBox(handles.requestsListbox, guiRequests);
        
        handles.ViewedRequestIndex = [];
        guidata(hObject, handles);
    end
end


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dlg = ProgressDialog();
dlg.ShowTimeLeft = true;

progressUpdateTimer = timer('TimerFcn',@progressUpdateTimer_Callback, 'Period', 0.5, 'ExecutionMode', 'fixedDelay');

data.Solver = PopulationSolverHelper();
data.ProgressBar = dlg;
progressUpdateTimer.UserData = data;

LVGResults = WorkspaceHelper.GetLVGResultsHashFromWorkspace();
ME = [];

requests = get(handles.requestsListbox,'UserData');
internalRequests = RequestPropertyGrid.ConvertRequestToInternalRequest(requests);

start(progressUpdateTimer);

for i=1:numel(internalRequests)
    
    try        
        dlg.FractionComplete = 0;
        dlg.StatusMessage = sprintf('Processing Request %g/%g: "%s"',i,numel(internalRequests), internalRequests(i).RequestName);

        result = data.Solver.ProcessPopulationRequest(internalRequests(i));
        
        dlg.FractionComplete = 1;
        LVGResults.Put(internalRequests(i).RequestName,result);
    
    catch ME
        break;        
    end
    
end

stop(progressUpdateTimer);
delete(progressUpdateTimer);
delete(dlg);

if ~isempty(ME) && ~strcmp(ME.message, 'Operation terminated by user.')
    rethrow(ME);
end

function progressUpdateTimer_Callback(timerObject,eventdata)

userdata = timerObject.UserData;

try   
    if userdata.ProgressBar.FractionComplete ~= userdata.Solver.ProgressFraction
        userdata.ProgressBar.FractionComplete = userdata.Solver.ProgressFraction;
    end    
catch ME
    userdata.Solver.StopOperation = true;
end


% --- Executes on selection change in requestsListbox.
function requestsListbox_Callback(hObject, eventdata, handles)
% hObject    handle to requestsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns requestsListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from requestsListbox

selectedRequestIndex = get(hObject,'Value');
allRequests = get(hObject,'UserData');

%load new request
if ~isempty(selectedRequestIndex)
    request = allRequests(selectedRequestIndex);
    copyReq = request.Copy();
    RequestPropertyGrid.SetGridProperties(handles.requestPropertiesEditor, copyReq, false);    
    handles.ViewedRequestIndex = selectedRequestIndex;
end

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function requestsListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to requestsListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'UserData',LVGSolverPopulationRequest.empty(0, 1));

% --- Executes on button press in removeButton.
function removeButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isempty(handles.ViewedRequestIndex))
    RequestPropertyGrid.ResetGripProperties(handles.requestPropertiesEditor);

    RequestsListboxHelper.RemoveRequestFromListBox(handles.requestsListbox, handles.ViewedRequestIndex);
    
    handles.ViewedRequestIndex = [];
    guidata(hObject, handles);
end

% --- Executes on button press in saveChangesButton.
function saveChangesButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveChangesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%save current request
if ~isempty(handles.ViewedRequestIndex)
    RequestsListboxHelper.ReplaceRequestInListBox(handles.requestsListbox,handles.ViewedRequestIndex,handles.requestPropertiesEditor.Item);
end

% --- Executes during object creation, after setting all properties.
function processRequestsFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processRequestsFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

h = PropertyGrid(hObject, ...
    'Position', ...
    [0.49108367626886135,...
    0.17,...
    0.4883401920438957,...
    0.7949367088607595]);

handles.requestPropertiesEditor = h;
guidata(hObject,handles);
