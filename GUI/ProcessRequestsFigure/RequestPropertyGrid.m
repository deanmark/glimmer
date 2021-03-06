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

classdef RequestPropertyGrid
    %REQUESTPROPERTYGRID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        
        PropertyOrderList = {'RequestName','MoleculeFileName','RunTypeCode','BetaTypeCode','Temperature','VelocityDerivativeUnits','VelocityDerivative',...
            'CollisionPartners','Weights','CollisionPartnerDensities','MoleculeAbundanceRatios','ConstantNpartnerBydVdR','CollisionPartnerColumnDensity', 'BackgroundTemperature',...
            'NumLevelsForSolution','Finished','FirstPopulationGuess','DebugIndicators'};
        
    end
    
    methods(Static)
        
        function GUIRequest = ConvertRequestToGUIRequest (LVGRequest)
            
            GUIRequest = LVGSolverPopulationRequest.empty(0,1);
            
            for i=1:numel(LVGRequest)
                
                GUIRequest(i) = LVGRequest(i).Copy();
                
                %Run Type
                [runTypeNames,runTypeValues] = FileIOHelper.GetClassConstants('RunTypeCodes', false);
                GUIRequest(i).RunTypeCode = runTypeNames{runTypeValues==GUIRequest(i).RunTypeCode};
                
                %Beta Type
                [betaTypeNames,betaTypeValues] = FileIOHelper.GetClassConstants('BetaTypeCodes', false);
                GUIRequest(i).BetaTypeCode = betaTypeNames{betaTypeValues==GUIRequest(i).BetaTypeCode};
                
                %Velocity Derivate Type
                [dvdrTypeNames,dvdrTypeValues, dvdrDescription] = FileIOHelper.GetClassConstants('VelocityDerivativeUnits',true);
                GUIRequest(i).VelocityDerivativeUnits = dvdrDescription{dvdrTypeValues==GUIRequest(i).VelocityDerivativeUnits};
                
                %Collision partners & weights
                [collisionPartnerNames,collisionPartnerValues] = FileIOHelper.GetClassConstants('CollisionPartnersCodes', false);
                
                collPartnersWithWeights = zeros(numel(GUIRequest(i).CollisionPartners),2);
                collPartnersWithWeights(1:end,1) = GUIRequest(i).CollisionPartners;
                collPartnersWithWeights(1:end,2) = GUIRequest(i).Weights;
                sortrows(collPartnersWithWeights);
                GUIRequest(i).CollisionPartners = ismember(collisionPartnerValues , collPartnersWithWeights(1:end,1));
                GUIRequest(i).Weights = collPartnersWithWeights(1:end,2)';
                
            end
            
        end
        
        function LVGRequest = ConvertRequestToInternalRequest (GUIRequest)
            
            LVGRequest = LVGSolverPopulationRequest.empty(0,1);
            Molecules = WorkspaceHelper.GetMoleculesHashFromWorkspace();
            
            for i=1:numel(GUIRequest)                
                LVGRequest(i) = GUIRequest(i).Copy();
                
                %Run Type
                [runTypeNames,runTypeValues] = FileIOHelper.GetClassConstants('RunTypeCodes',false);
                LVGRequest(i).RunTypeCode = runTypeValues(strcmpi(runTypeNames,GUIRequest(i).RunTypeCode));
                
                %Beta Type
                [betaTypeNames,betaTypeValues] = FileIOHelper.GetClassConstants('BetaTypeCodes',false);
                LVGRequest(i).BetaTypeCode = betaTypeValues(strcmpi(betaTypeNames,GUIRequest(i).BetaTypeCode));
                
                %Velocity Derivate Type
                [dvdrTypeNames,dvdrTypeValues, dvdrDescription] = FileIOHelper.GetClassConstants('VelocityDerivativeUnits',true);
                LVGRequest(i).VelocityDerivativeUnits = dvdrTypeValues(strcmpi(dvdrDescription,GUIRequest(i).VelocityDerivativeUnits));
                
                %Collision partners & weights
                [collisionPartnerNames,collisionPartnerValues] = FileIOHelper.GetClassConstants('CollisionPartnersCodes',false);
                LVGRequest(i).CollisionPartners = collisionPartnerValues(GUIRequest(i).CollisionPartners);
               
            end
        end
        
        function SetGridProperties(PropertyGridHandle, GUIRequest, Readonly)
            
            properties = PropertyGridField.GenerateFrom(GUIRequest);
            
            Molecules = WorkspaceHelper.GetMoleculesHashFromWorkspace();
            moleculeNames = Molecules.Keys;
            
            prop = properties.FindByName('MoleculeFileName');
            prop.Type = PropertyType('char', 'row', moleculeNames);
            if Molecules.IsKey(GUIRequest.MoleculeFileName) || Readonly
                prop.Value = GUIRequest.MoleculeFileName;
            elseif numel(moleculeNames) > 0
                prop.Value = moleculeNames{1};
            else
                prop.Value = '';
            end
            
            [runTypeNames,runTypeValues] = FileIOHelper.GetClassConstants('RunTypeCodes',false);            
            prop =properties.FindByName('RunTypeCode');
            prop.Type = PropertyType('char', 'row', runTypeNames);
            
            [betaTypeNames,betaTypeValues] = FileIOHelper.GetClassConstants('BetaTypeCodes',false);
            prop =properties.FindByName('BetaTypeCode');
            prop.Type = PropertyType('char', 'row', betaTypeNames);
            
            [dvdrTypeNames,dvdrTypeValues, dvdrDescription] = FileIOHelper.GetClassConstants('VelocityDerivativeUnits',true);
            prop = properties.FindByName('VelocityDerivativeUnits');
            prop.Type = PropertyType('char', 'row', dvdrDescription);            
            
            [collisionPartnerNames,collisionPartnerValues] = FileIOHelper.GetClassConstants('CollisionPartnersCodes',false);
            prop =properties.FindByName('CollisionPartners');
            prop.Type = PropertyType('logical', 'row', collisionPartnerNames);

            prop =properties.FindByName('FirstPopulationGuess');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = true;

            prop =properties.FindByName('Weights');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false; 
            
            prop =properties.FindByName('Temperature');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false; 
                       
            prop =properties.FindByName('VelocityDerivative');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false; 

            prop =properties.FindByName('CollisionPartnerDensities');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false; 
            
            prop =properties.FindByName('MoleculeAbundanceRatios');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false; 
            
            prop =properties.FindByName('ConstantNpartnerBydVdR');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false;
            
            prop =properties.FindByName('NumLevelsForSolution');
            prop.Type = PropertyType('denserealdouble', 'scalar');
            prop.ReadOnly = false; 
            
            prop =properties.FindByName('CollisionPartnerColumnDensity');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false;
            
            %set readonly property
            for i=1:numel(properties)
                properties(i).ReadOnly = logical(Readonly);
                properties(i).Category = 'LVG Request';
            end
            
            %reorder properties
            if numel(RequestPropertyGrid.PropertyOrderList)~=numel(properties)
               error('Number of elements in RequestPropertyGrid.PropertyOrderList [%g] should equal the number of elements in properties [%g]', numel(RequestPropertyGrid.PropertyOrderList), numel(properties)); 
            end
            
            orderedProperties = PropertyGridField.empty(0, 1);
            
            for i=1:numel(RequestPropertyGrid.PropertyOrderList)
                orderedProperties(end+1) =properties.FindByName(RequestPropertyGrid.PropertyOrderList{i});
            end
            
            PropertyGridHandle.Bind(GUIRequest,orderedProperties);

        end
        
        function ResetGridProperties(PropertyGridHandle)
            
            PropertyGridHandle.Item = [];
            
        end
        
    end
    
end
