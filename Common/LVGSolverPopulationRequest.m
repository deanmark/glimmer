classdef LVGSolverPopulationRequest < handle
    
    properties (Access = public)
        
        MoleculeData; 
        BetaProvider;
        
        CollisionPartnerRates; 
        Weights; 
        Temperature; 
        CollisionPartnerDensities; 
        VelocityDerivative; 
        MoleculeDensity; 
        NumLevelsForSolution; 
        FirstPopulationGuess;
        CalculateIntensities;
        CloudColumnDensity;
        
    end
    
    methods(Access=public)
        
        function Req = LVGSolverPopulationRequest(MoleculeData, BetaProvider, CollisionPartnerRates, Weights, Temperature, CollisionPartnerDensities, ...
                VelocityDerivative, MoleculeDensity, NumLevelsForSolution, FirstPopulationGuess, CalculateIntensities, CloudColumnDensity)
            
            if nargin ~= 0
                
                Req.MoleculeData = MoleculeData;
                Req.BetaProvider = BetaProvider;               
                
                Req.CollisionPartnerRates = CollisionPartnerRates;
                Req.Weights = Weights;
                Req.Temperature = Temperature;
                Req.CollisionPartnerDensities = CollisionPartnerDensities;
                Req.VelocityDerivative = VelocityDerivative;
                Req.MoleculeDensity = MoleculeDensity;
                Req.NumLevelsForSolution = NumLevelsForSolution;
                Req.FirstPopulationGuess = FirstPopulationGuess;
                Req.CalculateIntensities = CalculateIntensities;
                Req.CloudColumnDensity = CloudColumnDensity;
                
            end
        end
        
        function ReqCopy = Copy (rhs)
            
            p = inputParser();
            p.addRequired('rhs', @(x)isa(x,'LVGSolverPopulationRequest'));
            p.parse(rhs);
            
            ReqCopy = LVGSolverPopulationRequest();
            
            fns = properties(rhs);
            for i=1:length(fns)
                ReqCopy.(fns{i}) = rhs.(fns{i});
            end
            
        end
        
    end
    
end