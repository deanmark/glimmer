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
            
            if CurrentlyViewedIndex > numel(requests)
                newViewIndex = CurrentlyViewedIndex-1;
            else
                newViewIndex = CurrentlyViewedIndex;
            end
            
            set(ListBoxHandle,'Value',newViewIndex);
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

