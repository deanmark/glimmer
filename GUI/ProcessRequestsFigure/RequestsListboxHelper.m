classdef RequestsListboxHelper
    
    methods(Static)
                
        function AddRequestToListBox (ListBoxHandle, LVGPopRequest, CurrentlyViewedIndex)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = WorkspaceHelper.GetLVGRequestsListFromWorkspace();
            
            requestStrings{end+1} = LVGPopRequest.RequestName;
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
            
            requestStrings{OldRequestIndex} = newReq.RequestName;
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
                requestStrings{i} = Requests(i).RequestName;
            end
            
            set(ListBoxHandle,'Value',1);
            set(ListBoxHandle,'String',requestStrings);
            
        end
        
    end
end

