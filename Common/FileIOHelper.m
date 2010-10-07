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
        
        function [Names, Values, Description] = GetClassConstants (CurrentClass, getDescription)
            
            Names = {};
            Values = [];
            Description = {};
            
            getMetaDataCommand = sprintf('?%s',CurrentClass);
            metaData = eval(getMetaDataCommand);
            
            for prop=1:numel(metaData.Properties)
                
                property = metaData.Properties{prop};
                
                if property.Constant
                    Names{end+1} = property.Name;
                    getConstantValueCommand = sprintf('%s.%s',CurrentClass,property.Name);
                    Values(end+1) = eval(getConstantValueCommand);
                    
                    if (getDescription)
                        Description(end+1) = helptext(getConstantValueCommand);
                    end
                end
            end
            
        end
        
    end
    
end