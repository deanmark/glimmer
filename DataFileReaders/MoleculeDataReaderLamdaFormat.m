classdef MoleculeDataReaderLamdaFormat < MoleculeDataReader

    properties(Constant = true, Hidden=true)
        
        MoleculeNameString = 'MOLECULE';
        MoleculeEnergyLevelsString = 'NUMBER OF ENERGY LEVELS';
        MoleculeRadiativeTransitionsString = 'NUMBER OF RADIATIVE TRANSITIONS';
        
    end
    
    methods(Static=true)
        
        function Molecule = CreateMoleculeDataFromFile (FileName)
            
            [MoleculeName, PhotonFrequencies, EinsteinCoefficients, StatisticalWeights] = MoleculeDataReaderLamdaFormat.readMoleculeData(FileName);
            [pathstr, name, ext] = fileparts(FileName);
            Molecule = MoleculeData(MoleculeName, PhotonFrequencies, EinsteinCoefficients, strcat(name, ext), StatisticalWeights);
           
        end
        
    end
    
    methods(Static=true,Access = private, Hidden=true)
        
        function [MoleculeName, PhotonFrequencies, EinsteinCoefficients, StatisticalWeights] = readMoleculeData(FileName)
            
            fid = fopen(FileName);
            
            try
                currentLine = fgetl(fid);
                
                if isempty(strfind(upper(currentLine), MoleculeDataReaderLamdaFormat.MoleculeNameString))
                    ME = MException('MoleculeDataReaderLamdaFormat:MoleculeNameStringNotFound','Molecule name string was not found. Data file is not in the lamda format');
                    throw(ME);
                end
                
                currentLine = fgetl(fid);
                MoleculeName = strtrim(currentLine);
                
                currentLine = FileIOHelper.JumpLinesInFile (fid,3);
                
                if isempty(strfind(upper(currentLine), MoleculeDataReaderLamdaFormat.MoleculeEnergyLevelsString))
                    ME = MException('MoleculeDataReaderLamdaFormat:MoleculeEnergyLevelsStringNotFound','Molecule energy levels string was not found. Data file is not in the lamda format');
                    throw(ME);
                end
                
                currentLine = fgetl(fid);
                energyLevels = str2double (strtrim(currentLine));
                StatisticalWeights = zeros(energyLevels, 1);
                energies = zeros(energyLevels, 1); %energy in cm^-1
                PhotonFrequencies = zeros(energyLevels-1, 3); % frequency in Hz
                
                fgetl(fid);
                
                for i=1:energyLevels
                    currentLine = fgetl(fid);
                    rowData = regexp(strtrim(currentLine),'\s+','split');
                    StatisticalWeights(i) = str2double(rowData{3});
                    energies(i) = str2double(rowData{2});
                end
                
                PhotonFrequencies(:,1) = 2:energyLevels; %upper levels
                PhotonFrequencies(:,2) = 1:energyLevels-1; %lower levels
                PhotonFrequencies(:,3) = (energies(2:end) - energies(1:end-1))*Constants.c; % take delta(energy) and convert cm^-1 to Hz
                
                currentLine = fgetl(fid);
                
                if isempty(strfind(upper(currentLine), MoleculeDataReaderLamdaFormat.MoleculeRadiativeTransitionsString))
                    ME = MException('MoleculeDataReaderLamdaFormat:MoleculeRadiativeTransitionsStringNotFound','Molecule radiative transitions string string was not found. Data file is not in the lamda format');
                    throw(ME);
                end
                
                currentLine = fgetl(fid);
                radiativeTransitions = str2double (strtrim(currentLine));
                
                EinsteinCoefficients = zeros(radiativeTransitions, 3);
                
                fgetl(fid);
                
                for i=1:radiativeTransitions
                    
                    currentLine = fgetl(fid);
                    
                    rowData = regexp(strtrim(currentLine),'\s+','split');
                    EinsteinCoefficients(i,1) = str2double(rowData{2});
                    EinsteinCoefficients(i,2) = str2double(rowData{3});
                    EinsteinCoefficients(i,3) = str2double(rowData{4});
                    
                end
                
            catch
                fclose(fid);
                rethrow(lasterror);
            end
            
            fclose(fid);
            
        end

    end
    
end