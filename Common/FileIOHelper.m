classdef FileIOHelper
    
    methods(Static=true)
        
        function Path = ResultsPath ()            
            %returns path of current script.
            p = mfilename('fullpath'); 
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'Results');            
        end
        
        function Path = LamdaMolecularDataFilesPath ()            
            %returns path of current script.
            p = mfilename('fullpath'); 
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'DataFiles', 'Lamda');            
        end
        
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
        
        function Result = ConcatWithSeperator (StringsArray, SeperatorString)
            
            Result = '';
            
            if numel(StringsArray)==0
                return;
            else
                for i=1:numel(StringsArray)
                    if (~strcmp(StringsArray(i),''))
                        if (strcmp(Result,''))
                            Result = StringsArray(i);
                        else
                            Result = strcat(Result, SeperatorString, StringsArray(i));
                        end
                    end
                end
            end
        end
    end
    
end