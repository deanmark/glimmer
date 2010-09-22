classdef DataFilesHelper
    %DATAFILESHELPER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        function ConvertLamdaFileToLocalFile(FileName)
           
            fid = fopen(FileName, 'r+');
            
            try
                currentline = FileIOHelper.JumpLinesInFile(fid, 6);
                energyLevels = str2double(currentline);
                FileIOHelper.JumpLinesInFile(fid, 1);
                
                for i=1:energyLevels
                    
                    currentPosition = ftell(fid);
                    currentline = fgets(fid);
                    [matchstr splitstr] = regexp(currentline, '\s*', 'match', 'split');
                    
                    if isempty(splitstr{1})
                        pos = 5;
                    else
                        pos = 4;
                    end
                    
                    replacementString = blanks(numel(splitstr{pos}));
                    numStr = num2str(i-1);
                    replacementString(1:numel(numStr)) = numStr;
                    
                    if numel(splitstr{pos}) ~= numel(replacementString)
                        
                       diff = numel(replacementString) - numel(splitstr{pos});
                       matchingBlanks = matchstr{pos-1};
                       
                       if numel(matchingBlanks) <= diff
                          error('Unable to fix J text'); 
                       end
                       
                       matchstr{pos-1} = matchingBlanks(1:(numel(matchingBlanks)-diff));
                       
                    end
                    
                    splitstr{pos} = replacementString;
                    
                    j = [splitstr; [matchstr {''}]];
                    newLine = [j{:}];
                    
                    fseek(fid, currentPosition, 'bof');
                    fprintf(fid, newLine);
                    
                end
            catch ME
               fclose(fid);
               rethrow(ME);
            end
            
            fclose(fid);
        end
        
    end
    
end

