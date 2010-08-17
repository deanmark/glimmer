classdef LVGSolverPopulationRequest < handle
    
    properties (Access = public)
        
        CollisionPartnerRates; 
        Weights; 
        Temperature; 
        CollisionPartnerDensities; 
        VelocityDerivative; 
        MoleculeDensity; 
        NumLevelsForSolution; 
        FirstPopulationGuess;
        
    end
    
    methods(Access=public)
        
        function Req = LVGSolverPopulationRequest(CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities, VelocityDerivative, MoleculeDensity, NumLevelsForSolution, FirstPopulationGuess)
            
            Req.CollisionPartnerRates = CollisionPartnerRates;
            Req.Weights = Weights;
            Req.Temperature = Temperature;
            Req.CollisionPartnerDensities = CollisionPartnerDensities;
            Req.VelocityDerivative = VelocityDerivative;
            Req.MoleculeDensity = MoleculeDensity;
            Req.NumLevelsForSolution = NumLevelsForSolution;
            Req.FirstPopulationGuess = FirstPopulationGuess;
                        
        end
        
        function ReqCopy = Copy (obj)
           
           ReqCopy = LVGSolverPopulationRequest(obj.CollisionPartnerRates, obj.Weights, obj.Temperature, obj.CollisionPartnerDensities, ...
               obj.VelocityDerivative, obj.MoleculeDensity, obj.NumLevelsForSolution, obj.FirstPopulationGuess);
            
        end
        
    end
    
end