classdef MoleculeDataReaderRawFormat < MoleculeDataReader
    
    methods(Static=true)
        
        function Molecule = CreateMoleculeDataFromFile (FileName)
            
            [MoleculeName, PhotonFrequencies, EinsteinCoefficients] = MoleculeDataReaderRawFormat.readMoleculeData(FileName);
            [pathstr, name, ext] = fileparts(FileName);
            Molecule = MoleculeData(MoleculeName, PhotonFrequencies, EinsteinCoefficients, strcat(name, ext));
           
        end
        
    end
    
    methods(Static=true,Access = private, Hidden=true)
        
        function [MoleculeName, PhotonFrequencies, EinsteinCoefficients] = readMoleculeData(FileName)
            %IMPORTFILE(FILETOREAD1)
            %  Imports data from the specified file
            %  FILETOREAD1:  file to read
            
            %  Auto-generated by MATLAB on 03-Aug-2009 16:41:26
            
            % Import the file
            newData1 = importdata(FileName);
            
            MoleculeName = 'CO';
            
            MoleculeData = newData1.('data');            
            
            PhotonFrequencies = MoleculeData(:,[1 2 3]);
            EinsteinCoefficients = MoleculeData(:,[1 2 4]);
            
        end
        
    end
    
end