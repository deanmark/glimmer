classdef OpticalDepthProvider < handle
    
    properties(SetAccess = private)
        
        m_tauMatrix;
        
    end
    
    methods(Access=public)
        
        function ODepth = OpticalDepthProvider(MoleculeData)
            
            ODepth.m_tauMatrix = ODepth.buildTauMatrix(MoleculeData);
            
        end
        
        function TauCoefficients = CalculateTauCoefficients(obj, Population, MoleculeDensity, VelocityDerivative)
            
            TauCoefficients = ((obj.m_tauMatrix/VelocityDerivative)*(Population))*diag(MoleculeDensity);
            
        end
        
    end
    
    methods(Access=private)
        
        function TauMatrix = buildTauMatrix (obj, MoleculeData)
            
            TauMatrix = zeros (MoleculeData.MolecularLevels, MoleculeData.MolecularLevels);
            
            for i = 2:MoleculeData.MolecularLevels
                
                A = MoleculeData.EinsteinACoefficient(i,i-1);
                gHigh = MoleculeData.StatisticalWeight(i);
                gLow = MoleculeData.StatisticalWeight(i-1);
                freq = MoleculeData.TransitionFrequency(i, i-1);
                
                constPart = (A*Constants.c^3)/(8*Constants.pi*freq^3);
                
                TauMatrix(i, i-1) = constPart*gHigh/gLow;
                TauMatrix(i, i) = - constPart;
                
            end
            
        end
        
    end
    
end