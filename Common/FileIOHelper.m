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

classdef FileIOHelper
    
    methods(Static=true)

        function Path = ComparisonPicsOutputPath ()
            p = mfilename('fullpath'); 
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'Results', 'ComparisonOutput', 'pics');
        end        
        
        function Path = ComparisonOutputPath ()
            p = mfilename('fullpath');
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'Results', 'ComparisonOutput');
        end
        
        function Path = StandardMoleculeFilePath ()
            p = mfilename('fullpath'); 
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'Molecules.mat');
        end
        
        function Path = ResultsPath ()
            p = mfilename('fullpath'); 
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'Results');
        end
        
        function Path = LamdaMolecularDataFilesPath ()
            p = mfilename('fullpath'); 
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'DataFiles', 'Lamda');            
        end

        function Path = IconFilesPath ()
            p = mfilename('fullpath');
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'Gui', 'Icons');
        end
        
        function Path = ParforProgMonPath ()
            p = mfilename('fullpath');
            CommonDirectory = fileparts(p);
            Path = fullfile(CommonDirectory, '..', 'GUI', 'ParforProgMon');            
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
