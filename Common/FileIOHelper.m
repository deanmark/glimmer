classdef FileIOHelper
    
    methods(Static=true)
        
        function CurrentLine = JumpLinesInFile(fid,JumpSize)
            %returns the line that is JumpSize steps ahead of the current
            %line
            if JumpSize == 1
                CurrentLine = fgetl(fid);
                return;
            else
                for i=1:JumpSize-1
                    fgetl(fid);
                end
                
                CurrentLine = fgetl(fid);
            end
            
        end
    end
    
end