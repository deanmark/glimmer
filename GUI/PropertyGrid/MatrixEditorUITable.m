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

