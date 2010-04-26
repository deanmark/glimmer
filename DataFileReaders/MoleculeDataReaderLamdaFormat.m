classdef MoleculeDataReaderLamdaFormat < MoleculeDataReader
    
    properties(Constant = true, Hidden=true)
        
        MoleculeNameString = '!MOLECULE';
        MoleculeEnergyLevelsString = '!NUMBER OF ENERGY LEVELS';
        MoleculeRadiativeTransitionsString = '!NUMBER OF RADIATIVE TRANSITIONS';
        
    end
    
    methods(Static=true)
        
        function Molecule = CreateMoleculeDataFromFile (FileName)
            
            [MoleculeName, PhotonFrequencies, EinsteinCoefficients] = MoleculeDataReaderLamdaFormat.readMoleculeData(FileName);
            Molecule = MoleculeData(MoleculeName, PhotonFrequencies, EinsteinCoefficients);
           
        end
        
    end
    
    methods(Static=true,Access = private, Hidden=true)
        
        function [MoleculeName, PhotonFrequencies, EinsteinCoefficients] = readMoleculeData(FileName)
            
            fid = fopen(FileName);
            
            try
                currentLine = fgetl(fid);
                
                if strcmp(currentLine, MoleculeDataReaderLamdaFormat.MoleculeNameString)==false
                    ME = MException('MoleculeDataReaderLamdaFormat:MoleculeNameStringNotFound','Molecule name string was not found. Data file is not in the lamda format');
                    throw(ME);
                end
                
                currentLine = fgetl(fid);
                MoleculeName = currentLine;
                
                currentLine = FileIOHelper.JumpLinesInFile (fid,3);
                
                if strcmp(currentLine, MoleculeDataReaderLamdaFormat.MoleculeEnergyLevelsString)==false
                    ME = MException('MoleculeDataReaderLamdaFormat:MoleculeEnergyLevelsStringNotFound','Molecule energy levels string was not found. Data file is not in the lamda format');
                    throw(ME);
                end
                
                currentLine = fgetl(fid);
                energyLevels = str2double (currentLine);
                
                currentLine = FileIOHelper.JumpLinesInFile(fid,energyLevels+2);
                
                if strcmp(currentLine, MoleculeDataReaderLamdaFormat.MoleculeRadiativeTransitionsString)==false
                    ME = MException('MoleculeDataReaderLamdaFormat:MoleculeRadiativeTransitionsStringNotFound','Molecule radiative transitions string string was not found. Data file is not in the lamda format');
                    throw(ME);
                end
                
                currentLine = fgetl(fid);
                radiativeTransitions = str2double (currentLine);
                
                PhotonFrequencies = zeros(radiativeTransitions, 3);
                EinsteinCoefficients = zeros(radiativeTransitions, 3);
                
                fgetl(fid);
                
                for i=1:radiativeTransitions
                    
                    currentLine = fgetl(fid);
                    
                    rowData = regexp(strtrim(currentLine),' *','split');
                    
                    for j=1:size(rowData,2)-2
                        
                        if j==1 || j==2
                            PhotonFrequencies(i,j) = str2double(rowData(j+1));
                            EinsteinCoefficients(i,j) = str2double(rowData(j+1));
                        elseif j==3
                            EinsteinCoefficients(i,3) = str2double(rowData(j+1));
                        elseif j==4
                            PhotonFrequencies(i,3) = 10^9*str2double(rowData(j+1)); %frequency is in GHz, should be in Hz
                        end
                        
                    end
                    
                end
                
            catch
                fclose(fid);
                rethrow(lasterror);
            end
            
            fclose(fid);
            
        end

    end
    
end