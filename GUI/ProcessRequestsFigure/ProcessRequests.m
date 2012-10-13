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

% Last Modified by GUIDE v2.5 12-Oct-2012 16:25:44

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


% --- Executes on button press in addRequestsButton.
function addRequestsButton_Callback(hObject, eventdata, handles)
% hObject    handle to addRequestsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

requestStrings = get(handles.requestsListbox,'String');
[tmp extractedRequestStrings] = ...
    regexp(requestStrings,'(?<=<html><b>).*?(?=</b></html>)', 'tokens', 'match');

if isempty(extractedRequestStrings)
    extractedRequestStrings = '';
else
    extractedRequestStrings = [extractedRequestStrings{:}];
end

newRequestString = genvarname('Request', extractedRequestStrings);

innerRequest = LVGSolverPopulationRequest.DefaultRequest();
innerRequest.RequestName = newRequestString;

RequestsListboxHelper.AddRequestToListBox(handles.requestsListbox,innerRequest,handles.ViewedRequestIndex);



% --- Executes on button press in copyRequestsButton.
function copyRequestsButton_Callback(hObject, eventdata, handles)
% hObject    handle to copyRequestsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isempty(handles.ViewedRequestIndex))
    RequestsListboxHelper.DuplicateRequestInListBox(handles.requestsListbox, handles.ViewedRequestIndex);    
end

% --- Executes on button press in loadRequestsButton.
function refreshRequestsButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadRequestsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

internalRequests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();

RequestPropertyGrid.ResetGridProperties(handles.requestPropertiesEditor);

RequestsListboxHelper.SetRequestsToListBox(handles.requestsListbox, internalRequests);

handles.ViewedRequestIndex = [];
guidata(hObject, handles);

% --- Executes on button press in runRequestsButton.
function runRequestsButton_Callback(hObject, eventdata, handles)
% hObject    handle to runRequestsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

internalRequests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
validateRequests(internalRequests);

dlg = ProgressDialog();
dlg.ShowTimeLeft = true;

progressUpdateTimer = timer('TimerFcn',@progressUpdateTimer_Callback, 'Period', 0.5, 'ExecutionMode', 'fixedDelay');

data.Solver = PopulationSolverHelper();
data.ProgressBar = dlg;
progressUpdateTimer.UserData = data;

LVGResults = WorkspaceHelper.GetLVGResultsHashFromWorkspace();
ME = [];

start(progressUpdateTimer);

activeRequests = 0;

for i=1:numel(internalRequests)
    if ~internalRequests(i).Finished
        activeRequests = activeRequests + 1;
    end
end

requestId = 0;

for i=1:numel(internalRequests)
    
    if ~internalRequests(i).Finished
    
        requestId = requestId + 1;
        
        try
            dlg.FractionComplete = 0;
            dlg.StatusMessage = sprintf('Processing Request %g/%g: "%s"', requestId, activeRequests, internalRequests(i).RequestName);
            
            result = data.Solver.ProcessPopulationRequest(internalRequests(i));
            
            dlg.FractionComplete = 1;
            LVGResults.Put(internalRequests(i).RequestName,result);
            
        catch ME
            break;
        end
        
    end
    
end

stop(progressUpdateTimer);
delete(progressUpdateTimer);
delete(dlg);

refreshRequestsButton_Callback(handles.refreshRequestsButton, eventdata, handles);

if ~isempty(ME) && ~strcmp(ME.message, 'Operation terminated by user.')
    rethrow(ME);
end

function validateRequests (InternalRequests)

molecules = WorkspaceHelper.GetMoleculesHashFromWorkspace();

for i=1:numel(InternalRequests)
    
    req = InternalRequests(i);
    mol = molecules.Get(req.MoleculeFileName);
    
    if isempty(mol)        
        errMsg = sprintf('Error in request "%s". Molecule ''%s'' not loaded.', req.RequestName, InternalRequests(i).MoleculeFileName);
        errordlg(errMsg, 'Error', 'modal');
        error(errMsg);
    end
    
    for j=1:numel(req.CollisionPartners)
        
        partnerId = req.CollisionPartners(j);
        collisionParternObj = mol.GetCollisionPartner(partnerId);
        
        if isempty(collisionParternObj)            
            errMsg = sprintf('Error in request "%s". Molecule ''%s'' does not contain collision partner "%s".', req.RequestName, ...
                InternalRequests(i).MoleculeFileName, CollisionPartnersCodes.ToString(partnerId));
            errordlg(errMsg, 'Error', 'modal');
            error(errMsg);
        end
        
        maxReqTemp = max(req.Temperature);
        minReqTemp = min(req.Temperature);
        
        maxCollPartnerTemp = max(collisionParternObj.Temperatures);
        minCollPartnerTemp = min(collisionParternObj.Temperatures);

        if minReqTemp < minCollPartnerTemp || maxCollPartnerTemp < maxReqTemp
            errMsg = sprintf('Error in request "%s". For collision partner "%s" in molecule "%s", the allowed temperature range is %d-%d.', req.RequestName, ...
                CollisionPartnersCodes.ToString(partnerId), InternalRequests(i).MoleculeFileName, minCollPartnerTemp, minCollPartnerTemp);
            errordlg(errMsg, 'Error', 'modal');
            error(errMsg);
        end
        
    end
    
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
allRequests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();

%load new request
if ~isempty(selectedRequestIndex)
    internalRequest = allRequests(selectedRequestIndex);
    guiRequest = RequestPropertyGrid.ConvertRequestToGUIRequest(internalRequest);
    
    RequestPropertyGrid.SetGridProperties(handles.requestPropertiesEditor, guiRequest, false);    
end

handles.ViewedRequestIndex = selectedRequestIndex;
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

% refreshCallback = get(handles.refreshRequestsButton, 'Callback');
% refreshCallback(handles.refreshRequestsButton, []);

internalRequests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
RequestsListboxHelper.SetRequestsToListBox(hObject, internalRequests);

handles.ViewedRequestIndex = [];
guidata(hObject, handles);

% --- Executes on button press in removeRequestsButton.
function removeRequestsButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeRequestsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isempty(handles.ViewedRequestIndex))
    RequestPropertyGrid.ResetGridProperties(handles.requestPropertiesEditor);    
    RequestsListboxHelper.RemoveRequestFromListBox(handles.requestsListbox, handles.ViewedRequestIndex);    
    requestsListbox_Callback(handles.requestsListbox, eventdata, handles)
end

% --- Executes on button press in saveRequestsChangesButton.
function saveRequestsChangesButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveRequestsChangesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rawRequest = handles.requestPropertiesEditor.Item;
if numel(rawRequest.Weights) ~=sum(rawRequest.CollisionPartners)
            errMsg = sprintf('Error saving request. Weights and CollisionPartners arrays must have the same size.');
            errordlg(errMsg, 'Error', 'modal');
            error(errMsg);    
end

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

% --- Executes on button press in raiseRequestButton.
function raiseRequestButton_Callback(hObject, eventdata, handles)
% hObject    handle to raiseRequestButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.ViewedRequestIndex)
    if handles.ViewedRequestIndex > 1
        RequestsListboxHelper.SwitchRequestsInListBox(handles.requestsListbox,handles.ViewedRequestIndex,handles.ViewedRequestIndex-1);

        handles.ViewedRequestIndex = handles.ViewedRequestIndex - 1;
        guidata(hObject, handles);
    end
end


% --- Executes on button press in lowerRequestButton.
function lowerRequestButton_Callback(hObject, eventdata, handles)
% hObject    handle to lowerRequestButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.ViewedRequestIndex)
    requestStrings = get(handles.requestsListbox,'String');   
    
    if handles.ViewedRequestIndex < numel(requestStrings)
        RequestsListboxHelper.SwitchRequestsInListBox(handles.requestsListbox,handles.ViewedRequestIndex,handles.ViewedRequestIndex+1);

        handles.ViewedRequestIndex = handles.ViewedRequestIndex + 1;
        guidata(hObject, handles);
    end
end
