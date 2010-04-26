classdef CollisionRatesReader < handle
    
    methods(Abstract=true, Static=true)
        
        CollisionRates = CreateCollisionRatesFromFile (FileName, CollisionPartner, MoleculeData);
        
    end
    
end