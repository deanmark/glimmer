function varargout = DisplayRatios(varargin)
% DISPLAYRATIOS M-file for DisplayRatios.fig
%      DISPLAYRATIOS, by itself, creates a new DISPLAYRATIOS or raises the existing
%      singleton*.
%
%      H = DISPLAYRATIOS returns the handle to a new DISPLAYRATIOS or the handle to
%      the existing singleton*.
%
%      DISPLAYRATIOS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAYRATIOS.M with the given input arguments.
%
%      DISPLAYRATIOS('Property','Value',...) creates a new DISPLAYRATIOS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DisplayRatios_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DisplayRatios_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DisplayRatios

% Last Modified by GUIDE v2.5 27-Mar-2011 18:33:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DisplayRatios_OpeningFcn, ...
                   'gui_OutputFcn',  @DisplayRatios_OutputFcn, ...
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
end

% --- Executes just before DisplayRatios is made visible.
function DisplayRatios_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DisplayRatios (see VARARGIN)

% Choose default command line output for DisplayRatios
handles.output = hObject;

set(handles.displayRatiosButtongroup,'SelectionChangeFcn',@displayRatiosButtongroup_SelectionChangeFcn);
% Update handles structure

copyIconFilePath = fullfile (FileIOHelper.IconFilesPath, 'copy-icon.png');

copyIcon=imread(copyIconFilePath, 'BackgroundColor',[0.831 0.816 0.784]);
set(handles.copyRatiosDataButton,'CData',copyIcon);
set(handles.copyNominatorDataButton,'CData',copyIcon);
set(handles.copyDenominatorDataButton,'CData',copyIcon);

guidata(hObject, handles);

% UIWAIT makes DisplayRatios wait for user response (see UIRESUME)
% uiwait(handles.DisplayRatiosFigure);

end

% --- Outputs from this function are returned to the command line.
function varargout = DisplayRatios_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on selection change in upperResultsPopup.
function upperResultsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to upperResultsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns upperResultsPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from upperResultsPopup
end

% --- Executes during object creation, after setting all properties.
function upperResultsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperResultsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

results = WorkspaceHelper.GetLVGResultsHashFromWorkspace();
keys = results.Keys;

if ~isempty(keys)
    set(hObject,'String',keys);
else
    set(hObject,'String',{''});
end
end

% --- Executes on selection change in lowerResultsPopup.
function lowerResultsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to lowerResultsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lowerResultsPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lowerResultsPopup
end

% --- Executes during object creation, after setting all properties.
function lowerResultsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerResultsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

results = WorkspaceHelper.GetLVGResultsHashFromWorkspace();
keys = results.Keys;

if ~isempty(keys)
    set(hObject,'String',keys);
else
    set(hObject,'String',{''});
end
end

function upperLevelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to upperLevelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upperLevelEdit as text
%        str2double(get(hObject,'String')) returns contents of upperLevelEdit as a double
end

% --- Executes during object creation, after setting all properties.
function upperLevelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upperLevelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function lowerLevelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lowerLevelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lowerLevelEdit as text
%        str2double(get(hObject,'String')) returns contents of lowerLevelEdit as a double
end

% --- Executes during object creation, after setting all properties.
function lowerLevelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lowerLevelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function specificValuesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to specificValuesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of specificValuesEdit as text
%        str2double(get(hObject,'String')) returns contents of specificValuesEdit as a double
end

% --- Executes during object creation, after setting all properties.
function specificValuesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to specificValuesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function numberContoursEdit_Callback(hObject, eventdata, handles)
% hObject    handle to numberContoursEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberContoursEdit as text
%        str2double(get(hObject,'String')) returns contents of numberContoursEdit as a double
end

% --- Executes during object creation, after setting all properties.
function numberContoursEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberContoursEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function displayRatiosButtongroup_SelectionChangeFcn(hObject, eventdata)
 
%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject); 
 
switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'specificValuesRadiobutton'
        set(handles.specificValuesEdit, 'Enable', 'on');
        set(handles.numberContoursEdit, 'Enable', 'off');
    case 'numberContoursRadiobutton'
        set(handles.specificValuesEdit, 'Enable', 'off');
        set(handles.numberContoursEdit, 'Enable', 'on');
        
    otherwise
       % Code for when there is no match.
 
end
%updates the handles structure
guidata(hObject, handles);
end

% --- Executes on selection change in xAxisPopupmenu.
function xAxisPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to xAxisPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns xAxisPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xAxisPopupmenu
end

% --- Executes during object creation, after setting all properties.
function xAxisPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xAxisPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

[lvgParameterNames,lvgParameterValues] = FileIOHelper.GetClassConstants('LVGParameterCodes', false);

lvgParamGuiNames = {};

for lvgParam = lvgParameterValues
    lvgParamGuiNames{end+1} = LVGParameterCodes.ToStringGUIFormat(lvgParam);
end

set(hObject,'String',lvgParamGuiNames);
set(hObject,'Value',LVGParameterCodes.ConstantNpartnerBydVdR);
end
% --- Executes on selection change in yAxisPopupmenu.
function yAxisPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to yAxisPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns yAxisPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yAxisPopupmenu
end

% --- Executes during object creation, after setting all properties.
function yAxisPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yAxisPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

[lvgParameterNames,lvgParameterValues] = FileIOHelper.GetClassConstants('LVGParameterCodes', false);

lvgParamGuiNames = {};

for lvgParam = lvgParameterValues
    lvgParamGuiNames{end+1} = LVGParameterCodes.ToStringGUIFormat(lvgParam);
end

set(hObject,'String',lvgParamGuiNames);
set(hObject,'Value',LVGParameterCodes.CollisionPartnerDensity);
end

% --- Executes on selection change in comparisonTypePopupmenu.
function comparisonTypePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to comparisonTypePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns comparisonTypePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comparisonTypePopupmenu
end

% --- Executes during object creation, after setting all properties.
function comparisonTypePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comparisonTypePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

[comparisonTypeNames,comparisonTypeValues] = FileIOHelper.GetClassConstants('ComparisonTypeCodes', false);

comparisonTypeGuiNames = {};

for comparisonType = comparisonTypeValues
    comparisonTypeGuiNames{end+1} = ComparisonTypeCodes.ToStringGUIFormat(comparisonType);
end

set(hObject,'String',comparisonTypeGuiNames);
set(hObject,'Value',ComparisonTypeCodes.Intensities);
end

% --- Executes on button press in displayPushbutton.
function displayPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to displayPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nominatorName = getPopupmenuStringValue(handles.upperResultsPopup);
nominatorResult = WorkspaceHelper.GetLVGResultFromWorkspace(nominatorName);

denominatorName = getPopupmenuStringValue(handles.lowerResultsPopup);
denominatorResult = WorkspaceHelper.GetLVGResultFromWorkspace(denominatorName);

UpperLevel = str2double(get(handles.upperLevelEdit, 'String')) + 1;
LowerLevel = str2double(get(handles.lowerLevelEdit, 'String')) + 1;
LevelPair = [UpperLevel LowerLevel];

XAxisProperty = LVGParameterCodes.ToCodeFromGUIFormat(getPopupmenuStringValue(handles.xAxisPopupmenu));
YAxisProperty = LVGParameterCodes.ToCodeFromGUIFormat(getPopupmenuStringValue(handles.yAxisPopupmenu));

ComparisonTypeCode = ComparisonTypeCodes.ToCodeFromGUIFormat(getPopupmenuStringValue(handles.comparisonTypePopupmenu));

if ComparisonTypeCode == ComparisonTypeCodes.Intensities
    if nominatorResult.OriginalRequest.RunTypeCode ~= RunTypeCodes.Radex
        nominatorResult = IntensitiesHelper.PinColumnDensityToProperty(LVGParameterCodes.MoleculeAbundanceRatio, nominatorResult.OriginalRequest.MoleculeAbundanceRatios, nominatorResult);
    end
    
    if nominatorResult.OriginalRequest.RunTypeCode ~= RunTypeCodes.Radex
        denominatorResult = IntensitiesHelper.PinColumnDensityToProperty(LVGParameterCodes.MoleculeAbundanceRatio, denominatorResult.OriginalRequest.MoleculeAbundanceRatios, denominatorResult);
    end
end

ResultsPairs = [nominatorResult, denominatorResult];

[Ratios, RatioTitle, NominatorData, DenominatorData] = Scripts.CalculateResultsRatio(ResultsPairs, LevelPair, XAxisProperty, YAxisProperty, ComparisonTypeCode);
Ratios(Ratios<=0)=NaN;
Ratios(Ratios==Inf)=NaN;

plotTypeCode = getPlotTypeCode(handles);
ContourLevels = buildContourLevelsArray(handles);

set(handles.ratiosTable, 'Data', Ratios);
set(handles.nominatorTable, 'Data', NominatorData);
set(handles.denominatorTable, 'Data', DenominatorData);

DisplayDataCode = DisplayDataCodes.ToCodeFromGUIFormat(getPopupmenuStringValue(handles.displayDataPopupmenu));
Data = selectDisplayData(DisplayDataCode, Ratios, NominatorData, DenominatorData);
displayColorbar = logical(get(handles.colorbarCheckbox, 'Value'));

Scripts.DrawContours(Data, RatioTitle, ContourLevels, nominatorResult.OriginalRequest, XAxisProperty, YAxisProperty, plotTypeCode, ...
    'axesHandle', handles.ratiosAxes, 'toggleLegend', false, 'displayTitle', false, 'displayColorbar', displayColorbar);
end

function result = getPopupmenuStringValue (handle)

value = get(handle, 'Value');
strings = get(handle, 'String');
result = strings{value};
end 

function Data = selectDisplayData (DisplayDataCode, Ratios, NominatorData, DenominatorData)

switch DisplayDataCode
    case DisplayDataCodes.Ratios
        Data = Ratios;
    case DisplayDataCodes.Nominator
        Data = NominatorData;
    case DisplayDataCodes.Denominator
        Data = DenominatorData;
end
    
end


function result = getPlotTypeCode (handles)

selectedHandle = get(handles.graphTypeButtongroup, 'SelectedObject');
selectedName = get (selectedHandle, 'Tag');

switch selectedName
    case 'twoDimensionRadiobutton'
        result = PlotTypeCodes.TwoDimensionContour;
    case 'threeDimensionRadiobutton'
        result = PlotTypeCodes.ThreeDimensionContour;        
end
    
end

function result = buildContourLevelsArray (handles)

selectedHandle = get(handles.displayRatiosButtongroup, 'SelectedObject');
selectedName = get (selectedHandle, 'Tag');

switch selectedName
    case 'specificValuesRadiobutton'
        specificValues = str2num(get(handles.specificValuesEdit, 'String'));
        
        if numel(specificValues) == 1
            result = {[specificValues specificValues]};
        else
            result = {specificValues};
        end
    case 'numberContoursRadiobutton'
        numContours = str2double(get(handles.numberContoursEdit, 'String'));
        result = {numContours};
        
end
end


% --- Executes on button press in copyRatiosDataButton.
function copyRatiosDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to copyRatiosDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.ratiosTable,'Data');
num2clip(data);
end

% --- Executes on button press in copyNominatorDataButton.
function copyNominatorDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to copyNominatorDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.nominatorTable,'Data');
num2clip(data);
end

% --- Executes on button press in copyDenominatorDataButton.
function copyDenominatorDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to copyDenominatorDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.denominatorTable,'Data');
num2clip(data);
end


% --- Executes on selection change in displayDataPopupmenu.
function displayDataPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to displayDataPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns displayDataPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from displayDataPopupmenu
end

% --- Executes during object creation, after setting all properties.
function displayDataPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayDataPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

[displayDataNames,displayDataValues] = FileIOHelper.GetClassConstants('DisplayDataCodes', false);

displayDataGuiNames = {};

for displayData = displayDataValues
    displayDataGuiNames{end+1} = DisplayDataCodes.ToStringGUIFormat(displayData);
end

set(hObject,'String',displayDataGuiNames);
set(hObject,'Value',DisplayDataCodes.Ratios);
end


% --------------------------------------------------------------------
function refreshPushTool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to refreshPushTool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

upperResultsPopup_CreateFcn(handles.upperResultsPopup, eventdata, handles)
lowerResultsPopup_CreateFcn(handles.lowerResultsPopup, eventdata, handles)
    
end