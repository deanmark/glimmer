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

classdef RequestsListboxHelper
    
    methods(Static)
                
        function AddRequestToListBox (ListBoxHandle, LVGPopRequest, CurrentlyViewedIndex)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
            
            requestStrings{end+1} = RequestsListboxHelper.annotateRequestString(LVGPopRequest.RequestName,LVGPopRequest.Finished);
            requests(end+1) = LVGPopRequest;
            
            set(ListBoxHandle,'String',requestStrings);
            WorkspaceHelper.SetLVGRequestsListInWorkspace(requests);
            
            if (isempty(CurrentlyViewedIndex))
                set(ListBoxHandle,'Value',1);
            end
        end
        
        function ReplaceRequestInListBox(ListBoxHandle, OldRequestIndex, NewGUIRequest)
            
            newReq = RequestPropertyGrid.ConvertRequestToInternalRequest(NewGUIRequest);  
            
            requestStrings = get(ListBoxHandle,'String');
            requests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
            
            requestStrings{OldRequestIndex} = RequestsListboxHelper.annotateRequestString(newReq.RequestName,newReq.Finished);
            requests(OldRequestIndex) = newReq;
            
            set(ListBoxHandle,'String',requestStrings);
            WorkspaceHelper.SetLVGRequestsListInWorkspace(requests);
        end
        
        function RemoveRequestFromListBox (ListBoxHandle, CurrentlyViewedIndex)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
            
            requestStrings(CurrentlyViewedIndex) = [];
            requests(CurrentlyViewedIndex) = [];
            
            set(ListBoxHandle,'String',requestStrings);
            WorkspaceHelper.SetLVGRequestsListInWorkspace(requests);
            
            if numel(requests) == 0
                newViewIndex = [];
            elseif CurrentlyViewedIndex > numel(requests)
                newViewIndex = CurrentlyViewedIndex-1;
            else
                newViewIndex = CurrentlyViewedIndex;
            end
            
            set(ListBoxHandle,'Value',newViewIndex);
        end

        function SwitchRequestsInListBox (ListBoxHandle, CurrentIndex, NewIndex)
    
            requestStrings = get(ListBoxHandle,'String');
            requests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
            
            currentReqString = requestStrings(CurrentIndex);
            currentReq = requests(CurrentIndex);
            
            requestStrings(CurrentIndex) = requestStrings(NewIndex);
            requests(CurrentIndex) = requests(NewIndex);
            
            requestStrings(NewIndex) = currentReqString;
            requests(NewIndex) = currentReq;
            
            set(ListBoxHandle,'String',requestStrings);
            WorkspaceHelper.SetLVGRequestsListInWorkspace(requests);
            set(ListBoxHandle,'Value',NewIndex);
            
        end
        
        function DuplicateRequestInListBox (ListBoxHandle, CurrentlyViewedIndex)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
            
            requestStrings(CurrentlyViewedIndex+2:end+1) = requestStrings(CurrentlyViewedIndex+1:end);
            requests(CurrentlyViewedIndex+2:end+1) = requests(CurrentlyViewedIndex+1:end);
            
            requestStrings(CurrentlyViewedIndex+1) = requestStrings(CurrentlyViewedIndex);
            requests(CurrentlyViewedIndex+1) = requests(CurrentlyViewedIndex).Copy();
            
            set(ListBoxHandle,'String',requestStrings);
            WorkspaceHelper.SetLVGRequestsListInWorkspace(requests);
        end
        
        function SetRequestsToListBox (ListBoxHandle, Requests)
            
            requestStrings = cell(size(Requests));
            
            for i=1:numel(Requests)
                requestStrings{i} = RequestsListboxHelper.annotateRequestString(Requests(i).RequestName, Requests(i).Finished);
            end
            
            set(ListBoxHandle,'Value',1);
            set(ListBoxHandle,'String',requestStrings);
            
        end
        
    end
    
    methods(Static, Access = private)
        
        function ModifiedString = annotateRequestString(RequestName, RequestFinished)
        
            if ~RequestFinished
                ModifiedString = sprintf('<html><b>%s</b></html>', RequestName);
            else
                ModifiedString = RequestName;
            end                
            
        end
    end
end

