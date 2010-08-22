
%our calculation
%Temperatures = cat(2, 25:10:100, 100:100:2000);
%Temperatures = cat(2, 1700:100:2000);
%Temperatures = cat(2, 25:20:400, 400);
%Temperatures = cat(2, 100);

%Temperatures = CollisionRates_12CO_H2ortho.m_temperatures;
Temperatures = CollisionRates_HCOplus_H2.m_temperatures;
%Temperatures = CollisionRates_HCN_H2.m_temperatures;

%CollisionPartnerDensities = 10.^(5);
CollisionPartnerDensities = 10.^(2:1:7);
%CollisionPartnerDensities = 10.^(2.8:0.2:7);

ColumnDensities = [1];

% Molecule = MoleculeData_12CO;
% MoleculeToCollisionPartnerDensityRatio = 8e-5;
% CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
% CollisionPartnerWeights = [3 1];
%  
Molecule = MoleculeData_HCOplus;
MoleculeToCollisionPartnerDensityRatio = 10^-8;
CollisionPartners = [CollisionRates_HCOplus_H2];
CollisionPartnerWeights = [1];

% Molecule = MoleculeData_HCN;
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionRates_HCN_H2];
% CollisionPartnerWeights = [1];

%dvdrKmParsecArray = 1:0.05:1.05;
dvdrKmParsecArray = 1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

p = mfilename('fullpath'); %returns path of current script.
ScriptsDirectory = fileparts(p);
picsPath = fullfile(ScriptsDirectory, '..', 'Results', 'RadexCompareOutput', 'pics');
[status, message, messageid] = rmdir(picsPath, 's');
mkdir(picsPath);

Results = zeros(numel(Temperatures),numel(CollisionPartnerDensities));
for dvdrKmParsec = dvdrKmParsecArray
    for temp = Temperatures
        fprintf(1, 'Progress -> Temperature: %g\n', temp);
        
        for dens = CollisionPartnerDensities
            
            req = LVGSolverPopulationRequest(Molecule, BetaProvider, CollisionPartners, CollisionPartnerWeights, temp, dens, ...
                dvdrKmParsec*Constants.dVdRConversionFactor, dens*MoleculeToCollisionPartnerDensityRatio, Molecule.MolecularLevels, [], true, 1e5*dens*MoleculeToCollisionPartnerDensityRatio/(dvdrKmParsec*Constants.dVdRConversionFactor));
            
            RadexLVGResult = Scripts.CalculateRadexLVGPopulation (req);
            LVGResult = Scripts.CalculateLVGPopulation(req);            
            
            %Compare results using a graph
            %picFileName = sprintf('Temperature%g_%g.jpg',temp, find(dvdrKmParsecArray==dvdrKmParsec));
            picFileName = sprintf('Temperature%g_%g.jpg',temp, find(CollisionPartnerDensities==dens));
            FileName = fullfile(picsPath, picFileName);
%             

%             radexCmp = RadexLVGResult.FinalTauCoefficients;
%             ourCmp = LVGResult.FinalTauCoefficients;

            radexCmp = RadexLVGResult.Population;
            ourCmp = LVGResult.Population;
            
            %radexCmp = RadexLVGResult.Intensities;
            %ourCmp = LVGResult.Intensities;
            
            minLength = min(numel(radexCmp), numel(ourCmp));
            Scripts.CompareWithRadex(radexCmp, ourCmp, dens, temp, dvdrKmParsec, FileName);
            
            diff = Scripts.PopulationDiff(RadexLVGResult.Intensities, LVGResult.Intensities);
            
            %Results(find(Temperatures == temp,1),find(dvdrKmParsecArray == dvdrKmParsec,1)) = 100*max(diff);
            Results(find(Temperatures == temp,1),find(CollisionPartnerDensities == dens,1)) = 100*max(diff);
            if any (isnan(diff)) %|| RadexConverged == 0
                'Error'
            end
            
        end
    end
end

generateComparisonResport;