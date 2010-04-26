classdef MoleculeDataReader < handle
    
    methods(Abstract=true, Static=true)
        
        MoleculeData = CreateMoleculeDataFromFile (FileName);
        
    end
    
end

