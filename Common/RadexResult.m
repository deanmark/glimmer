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
        
        TransitionEnergy; % E_UP (K)
        Frquency; % FREQ (GHz)
        WaveLength; % WAVEL (um)
        ExcitationTemperature; % T_EX (K)
        Tau; % TAU
        RadiationTemeperature; % T_R (K)
        PopulationUp; % POP UP
        PopulationLow; % POP LOW
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
                rowData = regexp(strtrim(currentLine),' *','split');
                [pathstr, name, ext] = fileparts(char(rowData(6)));
                Result.MoleculeDataFile = strcat(name,ext);
                
                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),' *','split');
                Result.Temperature = str2double(rowData(4));
                
                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),' *','split');
                i=1;
                
                while strcmp(rowData(2),'Density')
                    Result.CollisionParters{i} = char(rowData(4));
                    Result.CollisionPartersDensity(i) = str2double(rowData(6));
                    i=i+1;
                    
                    currentLine = fgetl(fid);
                    rowData = regexp(strtrim(currentLine),' *','split');
                end
                
                Result.TBackground = str2double(rowData(4));
                
                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),' *','split');
                Result.ColumnDensity = str2double(rowData(5));

                currentLine = fgetl(fid);
                rowData = regexp(strtrim(currentLine),' *','split');
                Result.LineWidth = str2double(rowData(5));
                
            catch
                fclose(fid);
                rethrow(lasterror);
            end
            
            fclose(fid);
            
            DELIMITER = ' ';
            HEADERLINES = 10 + numel(Result.CollisionParters);

            % Import the file
            newData1 = importdata(FileName, DELIMITER, HEADERLINES);
            Result.TransitionEnergy = newData1.data(:,2);
            Result.Frquency = newData1.data(:,3);
            Result.WaveLength = newData1.data(:,4);
            Result.ExcitationTemperature = newData1.data(:,5);
            Result.Tau = newData1.data(:,6);
            Result.RadiationTemeperature = newData1.data(:,7);
            Result.PopulationUp = newData1.data(:,8);
            Result.PopulationLow = newData1.data(:,9);
            Result.Flux_K_km_s = newData1.data(:,10);
            Result.Flux_erg_cm2_s = newData1.data(:,11);
            
        end
        
    end
    
end

