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

classdef RadiationCalculator < handle
    
    properties(SetAccess = private)
        
        m_einsteinCoefficients;
        m_transitionEnergies;
        m_frequencies;
        m_statisticalWeightsRatio;
        
        m_expandingSphereBetaProvider;
        
    end
    
    methods(Access=public)
        
        function Calc = RadiationCalculator(MoleculeData, IncludeBackgroundRadiation, BackgroundTemperature)
            
            Calc.m_einsteinCoefficients = zeros(MoleculeData.MolecularLevels,1);
            Calc.m_transitionEnergies = zeros(MoleculeData.MolecularLevels,1);
            Calc.m_frequencies = zeros(MoleculeData.MolecularLevels,1);
            Calc.m_statisticalWeightsRatio = zeros(MoleculeData.MolecularLevels,1);
            
            HighLevels =  zeros(MoleculeData.MolecularLevels-1,1);
            HighLevels(:) = 2:MoleculeData.MolecularLevels;
            LowLevels = HighLevels - 1;
            
            Calc.m_einsteinCoefficients(2:end) = MoleculeData.EinsteinACoefficient(HighLevels, LowLevels);
            Calc.m_transitionEnergies(2:end) = MoleculeData.TransitionEnergy(HighLevels, LowLevels);
            Calc.m_frequencies(2:end) = MoleculeData.TransitionFrequency(HighLevels, LowLevels);
            Calc.m_statisticalWeightsRatio(2:end) = MoleculeData.StatisticalWeight(LowLevels)./MoleculeData.StatisticalWeight(HighLevels);
            
            Calc.m_expandingSphereBetaProvider = ExpandingSphereBetaProvider(MoleculeData, false, IncludeBackgroundRadiation, BackgroundTemperature);
            
        end
        
        function Intensities = CalculateIntegratedIntensityLVG(obj, LevelPopulation, TauCoefficients, MoleculeAbundanceRatio, CollisionPartnerColumnDensity)
            
            % (h nu) * x(i) * A(i) * Ntot * ((1 - exp(-tau))/tau) * BRF / 4 pi
            %BRF = BackgroundRadiationFactor = 1 - ( ((n(i)g(i+1)/(n(i+1)g(i))) -1) / (exp((h * nu) / (k * Tbg)) - 1)
            %units: erg cm-2 s-1
            
            BetaCoefficients = obj.m_expandingSphereBetaProvider.TauCoefficientsToBetaCoefficients(TauCoefficients);
            
            if (obj.m_expandingSphereBetaProvider.IncludeBackgroundRadiation)
                BetaCoefficients = BetaCoefficients .* obj.m_expandingSphereBetaProvider.m_cosmicBackgroundProvider.BackgroundRadiationFactor(LevelPopulation);
            end
            
            Intensities = (LevelPopulation.*obj.m_einsteinCoefficients.*obj.m_transitionEnergies.*BetaCoefficients*MoleculeAbundanceRatio*CollisionPartnerColumnDensity)/(4*Constants.pi);
            
        end
        
        function IntensityTemperatureUnits = CalculateIntegratedIntensityInTemperatureUnits(obj, LevelPopulation, TauCoefficients, MoleculeAbundanceRatio, CollisionPartnerColumnDensity)
            
            Intensity = obj.CalculateIntegratedIntensityLVG(LevelPopulation, TauCoefficients, MoleculeAbundanceRatio, CollisionPartnerColumnDensity);
            IntensityTemperatureUnits = (Intensity ./ (obj.m_frequencies .^ 3)) * Constants.c ^ 3 / (2 * Constants.k);
            
        end
        
        function Flux = CalculateFluxLTE(obj, Temperature, MoleculeAbundanceRatio)
            
            %(2 h nu^3 / c^2) (1/[exp(h nu / kT) - 1])
            
            Flux = (2 * Constants.h * obj.m_frequencies.^ 3 * MoleculeAbundanceRatio / Constants.c^2) .* (1./(exp(Constants.h * obj.m_frequencies / (Constants.k * Temperature))-1));
            Flux(1)=0;
            
        end
        
        function ExcitationTemp = CalculateExcitationTemperature(obj, LevelPopulation)
            
            % h nu(i+1,i) / (k log ( n(i) g(i+1) / (n(i+1) g(i)) ))
            
            levelPopulationRatio = zeros(size(LevelPopulation));
            levelPopulationRatio(2:end) = LevelPopulation(1:end-1)./LevelPopulation(2:end);
            ExcitationTemp = obj.m_transitionEnergies./(Constants.k * log(levelPopulationRatio./obj.m_statisticalWeightsRatio));
            
        end
        
        function RadiationTemperature = CalculateRadiationTemperature (obj, LevelPopulation, TauCoefficients)
            
            ExcitationTemperature = obj.CalculateExcitationTemperature(LevelPopulation);
            
            RadiationTemperature = ExcitationTemperature .* (1-exp(-TauCoefficients))  +  obj.m_expandingSphereBetaProvider.m_cosmicBackgroundProvider.BackgroundTemperature * exp(-TauCoefficients);
            RadiationTemperature(1)=0;
            
        end
        
        
    end
    
end
