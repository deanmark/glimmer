classdef LVGSolverPopulationRequest < handle
    
    properties (Access = public)
        
        RunTypeCode;
        MoleculeFileName; 
        
        BetaTypeCode;
        BackgroundTemperature;
        
        CollisionPartners; 
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
        
        function Req = LVGSolverPopulationRequest(RunTypeCode, MoleculeFileName, BetaTypeCode, BackgroundTemperature, CollisionPartners, Weights, Temperature, CollisionPartnerDensities, ...
                VelocityDerivative, MoleculeDensity, NumLevelsForSolution, FirstPopulationGuess, CalculateIntensities, CloudColumnDensity)
            
            if nargin ~= 0
                
                Req.RunTypeCode = RunTypeCode;
                Req.MoleculeFileName = MoleculeFileName;
                
                Req.BetaTypeCode = BetaTypeCode;               
                Req.BackgroundTemperature = BackgroundTemperature;               
                
                Req.CollisionPartners = CollisionPartners;
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