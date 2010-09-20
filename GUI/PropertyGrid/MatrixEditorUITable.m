classdef MatrixEditorUITable < handle
    
    properties       
        Data;        
    end
    
    methods
       
        function this = MatrixEditorUITable(varargin)
            
            h = uitable(varargin{:},...
                'CellEditCallback', @(hObject,eventdata)MatrixEditorUITable.uitable_CellEditCallback(hObject,eventdata,guidata(hObject)),...
                'DeleteFcn', @(hObject,eventdata)MatrixEditorUITable.uitable_DeleteCallback(hObject,eventdata,guidata(hObject)));
            
            handles.MatrixEditorObj = this;
            guidata(h,handles);
            
        end
        
    end
    
    methods(Static)
        
        function uitable_DeleteCallback(hObject, eventdata, handles)
        
            handles.MatrixEditorObj.Data = get(hObject, 'data');
            
        end        
        
        function uitable_CellEditCallback(hObject, eventdata, handles)
            
            tableData = get(hObject, 'data');
            newData = str2num(eventdata.EditData);            
            
            if isnumeric(newData) && isscalar(newData) && ~isnan(newData) 
                tableData(eventdata.Indices(1), eventdata.Indices(2)) = newData;
            else
                tableData(eventdata.Indices(1), eventdata.Indices(2)) = eventdata.PreviousData;
            end
            
            set(hObject, 'data', tableData);
            
        end
        
        
    end
    
end

