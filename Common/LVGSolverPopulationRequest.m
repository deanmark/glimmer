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
        %Sets the units of the velocity derivative.
        VelocityDerivativeUnits;
        %Sets the velocity derivative of the cloud.
        VelocityDerivative; 
        
        %Sets the Collision Partner Density. Units: cm^-3
        CollisionPartnerDensities;         
        %Sets the Molecule Abundance Ratios. Units: cm^-3
        MoleculeAbundanceRatios;
         
        %By setting this you MUST set 0 for CollisionPartnerDensities or VelocityDerivative. This sets Npartner/dvdr = const. Units: cm^-3 s
        ConstantNpartnerBydVdR;
        
        %Specifies if the request has run or not. To rerun requests, set this to false.
        Finished;
        
    end
    
    methods(Access=public)
        
        function Req = LVGSolverPopulationRequest(varargin)
            Req.Finished = false;
            constructor(Req, varargin{:});
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
            
            EqualParameters = LVGSolverPopulationRequest.areArraysIdentical(lhs.Temperature,rhs.Temperature) && ...
                LVGSolverPopulationRequest.areArraysIdentical(lhs.CollisionPartnerDensities,rhs.CollisionPartnerDensities) && ...
                LVGSolverPopulationRequest.areArraysIdentical(lhs.VelocityDerivative,rhs.VelocityDerivative) && ...
                lhs.VelocityDerivativeUnits == rhs.VelocityDerivativeUnits;
        end
        
        function Req = DefaultRequest()
            
            MoleculeFileName = 'co.dat';
            %MoleculeFileName = 'hco+@xpol.dat';
            %MoleculeToCollisionPartnerDensityRatio = 10^-8;
            CollisionPartners = [CollisionPartnersCodes.H2para, CollisionPartnersCodes.H2ortho];
            CollisionPartnerWeights = [1 3];
            
            %Molecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(MoleculeFileName);
            %Temperatures = Molecule.GetCollisionPartner(CollisionPartners(1)).Temperatures;
            Temperatures = [100 200];
            
            %CollisionPartnerDensities = 15e3:1000:20e3;
            %a=(1:2:10)'*(10.^(3:1:7));
            %CollisionPartnerDensities = [a(:)'];
            CollisionPartnerDensities = 10.^[3:7];
            
            %MoleculeDensity = CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio;
            MoleculeAbundanceRatios = 8e-5;
            
            %dvdrKmParsecArray = 1:0.05:1.05 .* Constants.dVdRConversionFactor;
            dvdrArray = 10.^[ -5:1:1 ];
            dvdrArrayUnits = VelocityDerivativeUnits.kmSecParsec;
            
            BackgroundTemperature = 2.73;
            
            Req = LVGSolverPopulationRequest('RunTypeCode', RunTypeCodes.LVG, ...
                'MoleculeFileName', MoleculeFileName,...
                'BetaTypeCode', BetaTypeCodes.UniformSphere,...
                'BackgroundTemperature', BackgroundTemperature,...
                'CollisionPartners', CollisionPartners,...
                'Weights', CollisionPartnerWeights,...
                'Temperature',Temperatures,...
                'CollisionPartnerDensities',CollisionPartnerDensities,...
                'VelocityDerivativeUnits',dvdrArrayUnits,...
                'VelocityDerivative',dvdrArray,...
                'MoleculeAbundanceRatios',MoleculeAbundanceRatios,...
                'NumLevelsForSolution',0,...
                'FirstPopulationGuess',[],...
                'CalculateIntensities',true,...
                'DebugIndicators',false,...
                'ConstantNpartnerBydVdR', 0);
            
        end
        
    end
    
    methods(Static, Access=private)
        
        function Result = areArraysIdentical(lhs, rhs)            
            Result = all(size(lhs)==size(rhs)) && ...
                all(lhs == rhs);            
        end
        
    end
    
end