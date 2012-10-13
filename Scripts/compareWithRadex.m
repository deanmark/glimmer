
% MoleculeFileName = 'oatom.dat';
% MoleculeToCollisionPartnerDensityRatio = 4.57e-4/2;
% CollisionPartners = [CollisionPartnersCodes.H2ortho, CollisionPartnersCodes.H2para, CollisionPartnersCodes.H, CollisionPartnersCodes.electrons];
% CollisionPartnerWeights = [MoleculeToCollisionPartnerDensityRatio, MoleculeToCollisionPartnerDensityRatio, 1, MoleculeToCollisionPartnerDensityRatio];

% MoleculeFileName = 'oatom.dat';
% MoleculeToCollisionPartnerDensityRatio = 4.57e-4/2;
% CollisionPartners = [CollisionPartnersCodes.H2ortho, CollisionPartnersCodes.H2para, CollisionPartnersCodes.electrons ];
% CollisionPartnerWeights = [3 1 4*MoleculeToCollisionPartnerDensityRatio];

% MoleculeFileName = 'c+.dat';
% MoleculeToCollisionPartnerDensityRatio = 2.45e-4;
% CollisionPartners = [CollisionPartnersCodes.H2ortho, CollisionPartnersCodes.H2para, CollisionPartnersCodes.H, CollisionPartnersCodes.electrons];
% CollisionPartnerWeights = [MoleculeToCollisionPartnerDensityRatio, MoleculeToCollisionPartnerDensityRatio, 1, MoleculeToCollisionPartnerDensityRatio];

% MoleculeFileName = 'c+.dat';
% MoleculeToCollisionPartnerDensityRatio = 2.45e-4/2;
% CollisionPartners = [CollisionPartnersCodes.H2ortho, CollisionPartnersCodes.H2para, CollisionPartnersCodes.electrons ];
% CollisionPartnerWeights = [3 1 4*MoleculeToCollisionPartnerDensityRatio];
% 
% MoleculeFileName = 'catom.dat';
% MoleculeToCollisionPartnerDensityRatio = 2.45e-4/2;
% CollisionPartners = [CollisionPartnersCodes.H2ortho, CollisionPartnersCodes.H2para];
% CollisionPartnerWeights = [0.75 0.25];
%  
MoleculeFileName = 'co.dat';
MoleculeToCollisionPartnerDensityRatio = 8e-5;
CollisionPartners = [CollisionPartnersCodes.H2ortho,CollisionPartnersCodes.H2para];
CollisionPartnerWeights = [0.75 0.25];
% %
% MoleculeFileName = 'hco+@xpol.dat';
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionPartnersCodes.H2];
% CollisionPartnerWeights = [1];
% % % % % 
% MoleculeFileName = 'hcn.dat';
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionPartnersCodes.H2];
% CollisionPartnerWeights = [1];


%our calculation
%Temperatures = cat(2, 25:10:100, 100:100:2000);
%Temperatures = cat(2, 1700:100:2000);
%Temperatures = cat(2, 25:20:400, 400);
%Temperatures = cat(2, 3000);
Temperatures = 100;
Molecule = WorkspaceHelper.GetMoleculeDataFromWorkspace(MoleculeFileName);
%Temperatures = Molecule.GetCollisionPartner(CollisionPartners(1)).Temperatures;

CollisionPartnerDensities = 10.^(3);
%CollisionPartnerDensities = 10.^(1:1:7);
%CollisionPartnerDensities = 10.^(2.8:0.2:7);

ColumnDensities = [1];
 

%dvdrKmParsecArray = 1:0.05:1.05;
dvdrArray = 1;
dvdrArrayUnits = VelocityDerivativeUnits.kmSecParsec;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;

p = mfilename('fullpath'); %returns path of current script.
ScriptsDirectory = fileparts(p);
picsPath = fullfile(ScriptsDirectory, '..', 'Results', 'RadexCompareOutput', 'pics');
[status, message, messageid] = rmdir(picsPath, 's');
mkdir(picsPath);

DiffGrid = zeros(numel(Temperatures),numel(CollisionPartnerDensities));
for dvdrKmParsec = dvdrKmParsecArray
    for temp = Temperatures
        fprintf(1, 'Progress -> Temperature: %g\n', temp);
        
        for dens = CollisionPartnerDensities
            
            lvgReq = LVGSolverPopulationRequest('RunTypeCode', RunTypeCodes.LVG, ...
                'MoleculeFileName', MoleculeFileName,...
                'BetaTypeCode', BetaTypeCodes.UniformSphere,...
                'BackgroundTemperature', BackgroundTemperature,...
                'CollisionPartners', CollisionPartners,...
                'Weights', CollisionPartnerWeights,...
                'Temperature',Temperatures,...
                'CollisionPartnerDensities',CollisionPartnerDensities,...
                'VelocityDerivativeUnits',dvdrArrayUnits,...
                'VelocityDerivative',dvdrArray,...
                'MoleculeAbundanceRatios',MoleculeToCollisionPartnerDensityRatio,...
                'NumLevelsForSolution',0,...
                'FirstPopulationGuess',[],...
                'CollisionPartnerColumnDensity',1e5*CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio/(dvdrArray*VelocityDerivativeUnits.ConversionFactorToCGS(VelocityDerivativeUnits.kmSecParsec)),...
                'DebugIndicators',false,...
                'ConstantNpartnerBydVdR', 0);            
           
            solver = PopulationSolverHelper();
            
            radexReq = lvgReq.Copy();
            radexReq.RunTypeCode = RunTypeCodes.Radex;
                                    
            RadexLVGResult = solver.ProcessPopulationRequest(radexReq);
            LVGResult = solver.ProcessPopulationRequest(lvgReq);
            
            %Compare results using a graph
            %picFileName = sprintf('Temperature%g_%g.jpg',temp, find(dvdrKmParsecArray==dvdrKmParsec));
            picFileName = sprintf('Temperature%g_%g.jpg',temp, find(CollisionPartnerDensities==dens));
            FileName = fullfile(picsPath, picFileName);
            %
            
            %radexCmp = RadexLVGResult.FinalTauCoefficients;
            %ourCmp = LVGResult.FinalTauCoefficients;
            
            radexCmp = RadexLVGResult.Population;
            ourCmp = LVGResult.Population;
            
            %radexCmp = RadexLVGResult.Intensities;
            %ourCmp = LVGResult.Intensities;
            
            minLength = min(numel(radexCmp), numel(ourCmp));
            Scripts.CompareWithRadex(radexCmp, ourCmp, dens, temp, dvdrKmParsec, FileName);
            
            diff = Scripts.PopulationDiff(radexCmp, ourCmp);
            
            %DiffGrid(find(Temperatures == temp,1),find(dvdrKmParsecArray == dvdrKmParsec,1)) = 100*max(diff);
            DiffGrid(find(Temperatures == temp,1),find(CollisionPartnerDensities == dens,1)) = 100*max(diff);
            if any (isnan(diff)) %|| RadexConverged == 0
                'Error'
            end
            
        end
    end
end

generateComparisonResport(Temperatures, CollisionPartnerDensities, DiffGrid);