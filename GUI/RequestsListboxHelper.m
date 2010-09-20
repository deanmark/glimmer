classdef RequestsListboxHelper
    
    methods(Static)
                
        function AddRequestToListBox (ListBoxHandle, GUIRequest, CurrentlyViewedIndex)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = get(ListBoxHandle,'UserData');
            
            requestStrings{end+1} = GUIRequest.RequestName;
            requests(end+1) = GUIRequest;
            
            set(ListBoxHandle,'String',requestStrings);
            set(ListBoxHandle,'UserData',requests);
            
            if (isempty(CurrentlyViewedIndex))
                set(ListBoxHandle,'Value',1);
            end
        end
        
        function ReplaceRequestInListBox(ListBoxHandle, OldRequestIndex, NewGUIRequest)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = get(ListBoxHandle,'UserData');
            
            requestStrings{OldRequestIndex} = NewGUIRequest.RequestName;
            requests(OldRequestIndex) = NewGUIRequest;
            
            set(ListBoxHandle,'String',requestStrings);
            set(ListBoxHandle,'UserData',requests);
        end
        
        function RemoveRequestFromListBox (ListBoxHandle, CurrentlyViewedIndex)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = get(ListBoxHandle,'UserData');
            
            requestStrings(CurrentlyViewedIndex) = [];
            requests(CurrentlyViewedIndex) = [];
            
            set(ListBoxHandle,'String',requestStrings);
            set(ListBoxHandle,'UserData',requests);
            
            if CurrentlyViewedIndex>1
                newViewIndex = CurrentlyViewedIndex-1;
            else
                newViewIndex = 1;
            end
            
            set(ListBoxHandle,'Value',newViewIndex);
        end
        
        function DuplicateRequestInListBox (ListBoxHandle, CurrentlyViewedIndex)
            
            requestStrings = get(ListBoxHandle,'String');
            requests = get(ListBoxHandle,'UserData');
            
            requestStrings(CurrentlyViewedIndex+2:end+1) = requestStrings(CurrentlyViewedIndex+1:end);
            requests(CurrentlyViewedIndex+2:end+1) = requests(CurrentlyViewedIndex+1:end);
            
            requestStrings(CurrentlyViewedIndex+1) = requestStrings(CurrentlyViewedIndex);
            requests(CurrentlyViewedIndex+1) = requests(CurrentlyViewedIndex).Copy();
            
            set(ListBoxHandle,'String',requestStrings);
            set(ListBoxHandle,'UserData',requests);
        end
        
        function SetRequestsToListBox (ListBoxHandle, Requests)
            
            requestStrings = cell(size(Requests));
            
            for i=1:numel(Requests)
                requestStrings{i} = Requests(i).RequestName;
            end
            
            set(ListBoxHandle,'Value',1);
            set(ListBoxHandle,'String',requestStrings);
            set(ListBoxHandle,'UserData',Requests);
            
            
        end
        
    end
end

