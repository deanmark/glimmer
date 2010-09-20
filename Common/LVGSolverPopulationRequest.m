classdef LVGSolverPopulationRequest < handle
    
    properties (Access = public)
        
        %Specifies which calculation type to use for the computation.
        RunTypeCode;
        %LAMDA molecule file name
        MoleculeFileName; 
        %Specifies a unique title name for the request
        RequestName;
        
        %Specifies what type of beta calculation to use
        BetaTypeCode;
        %Specifies the cosmic background radiation temperature. Set = 0 to ignore background radiation. Units: Kelvin
        BackgroundTemperature;
                
        %Sets the number of molecule levels to use in the solution. Leave empty for the maximum number of levels.
        NumLevelsForSolution; 
        %This is an internal property. Leave this empty in normal use. It sets the first fractional population guess for the LVG iterative solution. Should be of size NumLevelsForSolution.
        FirstPopulationGuess;
        %Sets whether the intensities should be calculated.
        CalculateIntensities;
        %This is an internal property. Leave this empty in normal use. This sets whether debug indicators should be returned after an LVG run. WARNING: This slows the code down by a factor of ~4.
        DebugIndicators;
        
        %Specifies the collision partner codes
        CollisionPartners; 
        %Sets the relative weight of each collision partner in the total collision partner density
        Weights;         
        %Sets the cloud kinetic temperature. This affects the collision rates. Leave empty to set to the temperatures in the LAMDA file. Units: Kelvin
        Temperature; 
        %Sets the velocity derivative of the cloud. Units: s^-1
        VelocityDerivative; 
        
        %Sets the Collision Partner Density. Units: cm^-3
        CollisionPartnerDensities;         
        %Sets the Molecule Density. Units: cm^-3
        MoleculeDensity; 
        %Sets the Cloud Column Density. This only affects the calculation of the intensity. Units: cm^-3
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
                
                Req.DebugIndicators = 0;
                
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
    
    methods(Static, Access=public)
    
        function [EqualParameters] = EqualParameterSpace(lhs, rhs)
            
            p = inputParser();
            p.addRequired('lhs', @(x)isa(x,'LVGSolverPopulationRequest'));
            p.addRequired('rhs', @(x)isa(x,'LVGSolverPopulationRequest'));
            p.parse(lhs, rhs);
            
            EqualParameters = LVGSolverPopulationRequest.areArraysIdentical(lhs.Temperature,lhs.Temperature) && ...
                LVGSolverPopulationRequest.areArraysIdentical(lhs.CollisionPartnerDensities,lhs.CollisionPartnerDensities) && ...
                LVGSolverPopulationRequest.areArraysIdentical(lhs.VelocityDerivative,lhs.VelocityDerivative) && ...
                LVGSolverPopulationRequest.areArraysIdentical(lhs.MoleculeDensity,lhs.MoleculeDensity);
        end
        
        function Req = DefaultRequest()
            
            MoleculeFileName = 'hcn.dat';
            %MoleculeFileName = 'hco+@xpol.dat';
            %MoleculeToCollisionPartnerDensityRatio = 10^-8;
            CollisionPartners = [CollisionPartnersCodes.H2];
            CollisionPartnerWeights = [1];
            
            Molecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(MoleculeFileName);
            %Temperatures = Molecule.GetCollisionPartner(CollisionPartners(1)).Temperatures;
            Temperatures = 60;
            
            %CollisionPartnerDensities = 15e3:1000:20e3;
            a=(1:2:10)'*(10.^(3:1:7));
            CollisionPartnerDensities = [a(:)'];
            %CollisionPartnerDensities = 1e4:1000:4e4;
            
            %MoleculeDensity = CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio;
            MoleculeDensity = ones(size(CollisionPartnerDensities)).*10^6*2;
            ColumnDensities = MoleculeDensity;
            
            %dvdrKmParsecArray = 1:0.05:1.05 .* Constants.dVdRConversionFactor;
            dvdrArray = 10.^[ -5:1:1 ];
            
            BackgroundTemperature = 2.73;
            
            Req = LVGSolverPopulationRequest();
            constructor(Req, ... 
                'RunTypeCode', RunTypeCodes.LVG, ...
                'MoleculeFileName', MoleculeFileName,...
                'BetaTypeCode', BetaTypeCodes.UniformSphere,...
                'BackgroundTemperature', BackgroundTemperature,...
                'CollisionPartners', CollisionPartners,...
                'Weights', CollisionPartnerWeights,...
                'Temperature',Temperatures,...
                'CollisionPartnerDensities',CollisionPartnerDensities,...
                'VelocityDerivative',dvdrArray,...
                'MoleculeDensity',MoleculeDensity,...
                'NumLevelsForSolution',0,...
                'FirstPopulationGuess',[],...
                'CalculateIntensities',true,...
                'CloudColumnDensity',ColumnDensities,...
                'DebugIndicators',false);
            
        end
        
    end
    
    methods(Static, Access=private)
        
        function Result = areArraysIdentical(lhs, rhs)            
            Result = all(size(lhs)==size(rhs)) && ...
                all(lhs == rhs);            
        end
        
    end
    
end