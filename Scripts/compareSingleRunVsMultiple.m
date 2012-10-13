%{
GLIMMER is a visual LVG (Large Velocity Gradient) analysis tool.

Copyright (C) 2012  Dean Mark <deanmark at gmail>, 
		Prof. Amiel Sternberg <amiel at wise.tau.ac.il>, 
		Department of Astrophysics, Tel-Aviv University

Documentation for the program is posted at http://deanmark.github.com/glimmer/

This file is part of GLIMMER.

GLIMMER is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GLIMMER is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%}

%our calculation
%Temperatures = cat(2, 25:10:100, 100:100:2000);
Temperatures = cat(2, 1700:100:2000);
%Temperatures = cat(2, 25:20:400, 400);
%Temperatures = 200;

%Temperatures = CollisionRates_12CO_H2ortho.m_temperatures;
%Temperatures = CollisionRates_HCOplus_H2.m_temperatures;
%Temperatures = CollisionRates_HCN_H2.m_temperatures;

%CollisionPartnerDensities = 10.^(5);
%CollisionPartnerDensities = 10.^(3:0.2:6);
CollisionPartnerDensities = 10.^(5:1:6);

ColumnDensities = [1];

Molecule = MoleculeData_12CO;
MoleculeToCollisionPartnerDensityRatio = 8e-5;
CollisionPartners = [CollisionRates_12CO_H2ortho,CollisionRates_12CO_H2para];
CollisionPartnerWeights = [0.75 0.25];
%  
% Molecule = MoleculeData_HCOplus;
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionRates_HCOplus_H2];
% CollisionPartnerWeights = [1];

% Molecule = MoleculeData_HCN;
% MoleculeToCollisionPartnerDensityRatio = 10^-8;
% CollisionPartners = [CollisionRates_HCN_H2];
% CollisionPartnerWeights = [1];

dvdrKmParsecArray = 1:0.05:1.05;
%dvdrKmParsecArray = 1;

BackgroundTemperature = 2.73;

IgnoreNegativeTau = false;
IncludeBackgroundRadiation = true;

%BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
%BetaProvider = UniformSphereBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);
BetaProvider = HomogeneousSlabBetaProvider(Molecule, IgnoreNegativeTau, IncludeBackgroundRadiation, BackgroundTemperature);

req1 = LVGSolverPopulationRequest(Molecule, BetaProvider, CollisionPartners, CollisionPartnerWeights, Temperatures, CollisionPartnerDensities, ...
    dvdrKmParsecArray*Constants.dVdRConversionFactor, CollisionPartnerDensities*MoleculeToCollisionPartnerDensityRatio, Molecule.MolecularLevels, [], true, ones([1 numel(CollisionPartnerDensities)]));


fprintf(1, 'Computing script output\n');
LVGResultMultiple = Scripts.CalculateLVGPopulation(req1);

foundError = false;
maxDiffPop = 0;
maxDiffInt = 0;
maxDiffBeta = 0;

totalComputations = numel(dvdrKmParsecArray)*numel(Temperatures)*numel(CollisionPartnerDensities);
i = 0;

fprintf(1, 'Computing output one by one\n');

for dvdrIndex = 1:numel(dvdrKmParsecArray)
    
    dvdrKmParsec = dvdrKmParsecArray(dvdrIndex);
    
    for tempIndex = 1:numel(Temperatures)
        
        temp = Temperatures(tempIndex);
        
        for densIndex = 1:numel(CollisionPartnerDensities)
            
            dens = CollisionPartnerDensities(densIndex);
            
            req2 = LVGSolverPopulationRequest(Molecule, BetaProvider, CollisionPartners, CollisionPartnerWeights, temp, dens, ...
                dvdrKmParsec*Constants.dVdRConversionFactor, dens*MoleculeToCollisionPartnerDensityRatio, Molecule.MolecularLevels, [], true, 1);
            
            LVGResultSingle = Scripts.CalculateLVGPopulation(req2);
            
            popDiff = Scripts.PopulationDiff(LVGResultSingle.Population(:),LVGResultMultiple.Population(:,tempIndex,densIndex,dvdrIndex));
            intDiff = Scripts.PopulationDiff(LVGResultSingle.Intensities(:),LVGResultMultiple.Intensities(:,tempIndex,densIndex,dvdrIndex));
            betaDiff = Scripts.PopulationDiff(LVGResultSingle.FinalBetaCoefficients(:),LVGResultMultiple.FinalBetaCoefficients(:,tempIndex,densIndex,dvdrIndex));
            
            if any(LVGResultMultiple.Population(:,tempIndex,densIndex,dvdrIndex) ~= LVGResultSingle.Population(:)) && ...
                    any(LVGResultMultiple.Intensities(:,tempIndex,densIndex,dvdrIndex) ~= LVGResultSingle.Intensities(:))
                
                foundError = true;
                maxDiffPop = max(maxDiffPop,max(popDiff));
                maxDiffInt = max(maxDiffInt,max(intDiff));
                maxDiffBeta = max(maxDiffBeta,max(betaDiff));
                
            end
            
            if totalComputations > 1
                i=i+1;
                progress = i/totalComputations;
                fprintf(1, 'Progress: %%%3d\n', floor(100*progress));
            end
            
        end
        
    end
    
end

if foundError
    fprintf(1, 'There is a bug in the program\n');
else
    fprintf(1, 'Test has run smoothly\n');
end
