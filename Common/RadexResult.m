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

classdef RadexResult < handle
    %RADEXRESULT Contains all the results from a radex run.
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        
        Geometry;
        MoleculeDataFile;
        Temperature;
        CollisionParters;
        CollisionPartersDensity;
        TBackground;
        ColumnDensity;
        LineWidth;
        
        UpperStateEnergy; % E_UP (K)
        Frquency; % FREQ (GHz)
        WaveLength; % WAVEL (um)
        ExcitationTemperature; % T_EX (K)
        Tau; % TAU
        RadiationTemeperature; % T_R (K)
        Population;
        Flux_K_km_s; % FLUX (K*km/s)
        Flux_erg_cm2_s;% FLUX (erg/cm2/s)
        
    end
    
    methods(Access = public)
     
        function RR = RadexResult(MoleculeDataFile,Temperature,CollisionParters,CollisionPartersDensity,TBackground,ColumnDensity,LineWidth)
                
            if nargin > 0                
                RR.MoleculeDataFile = MoleculeDataFile;
                RR.Temperature = Temperature;
                RR.CollisionParters = CollisionParters;
                RR.CollisionPartersDensity = CollisionPartersDensity;
                RR.TBackground = TBackground;
                RR.ColumnDensity = ColumnDensity;
                RR.LineWidth = LineWidth;                
            end            
        end
        
    end
    
    methods(Static=true,Access = public, Hidden=true)
       
        function Result = ReadFromFile (FileName)
                       
            %read header info
            fid = fopen(FileName);
            
            if fid == -1
                ME = MException('VerifyInput:fileNotFound','Error in input. FileName [%s] not found', FileName);
                throw(ME);
            end
            
            Result = RadexResult();
            
            try
                
                currentLine = FileIOHelper.JumpLinesInFile(fid,2);
                rowData = regexp(strtrim(currentLine),':','split');
                Result.Geometry = strtrim(rowData(2));
                
                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),'\s*','split');
                [pathstr, name, ext] = fileparts(char(rowData(6)));
                Result.MoleculeDataFile = strcat(name,ext);
                
                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),'\s*','split');
                Result.Temperature = str2double(rowData(4));
                
                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),'\s*','split');
                i=1;
                
                while strcmp(rowData(2),'Density')
                    Result.CollisionParters{i} = char(rowData(4));
                    Result.CollisionPartersDensity(i) = str2double(rowData(6));
                    i=i+1;
                    
                    currentLine = fgetl(fid);
                    rowData = regexp(strtrim(currentLine),'\s*','split');
                end
                
                Result.TBackground = str2double(rowData(4));
                
                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),'\s*','split');
                Result.ColumnDensity = str2double(rowData(5));

                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),'\s*','split');
                Result.LineWidth = str2double(rowData(5));
                
                currentLine = FileIOHelper.JumpLinesInFile(fid,4);
                i = 1;                
                
                while currentLine ~= -1
                                    
                    rowData = regexp(strtrim(currentLine),'\s*','split');
                    
                    upperLevel(i,1) = str2double(rowData{1}) + 1;
                    lowerLevel(i,1) = str2double(rowData{3}) + 1;
                    Result.UpperStateEnergy(i,1) = str2double(rowData{4});
                    Result.Frquency(i,1) = str2double(rowData{5});
                    Result.WaveLength(i,1) = str2double(rowData{6});
                    Result.ExcitationTemperature(i,1) = str2double(rowData{7});
                    Result.Tau(i,1) = str2double(rowData{8});
                    Result.RadiationTemeperature(i,1) = str2double(rowData{9});
                    populationUp(i,1) = str2double(rowData{10});
                    populationLow(i,1) = str2double(rowData{11});
                    Result.Flux_K_km_s(i,1) = str2double(rowData{12});
                    Result.Flux_erg_cm2_s(i,1) = str2double(rowData{13});
                    
                    currentLine = fgetl(fid);                    
                    i = i+1;
                end
                
                Result.Population(upperLevel) = populationUp;
                Result.Population(lowerLevel) = populationLow;                
                
            catch
                fclose(fid);
                rethrow(lasterror);
            end
            
            fclose(fid);

        end
        
    end
    
end

