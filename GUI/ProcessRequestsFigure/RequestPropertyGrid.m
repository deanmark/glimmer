classdef RequestPropertyGrid
    %REQUESTPROPERTYGRID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        
        PropertyOrderList = {'RequestName','MoleculeFileName','RunTypeCode','BetaTypeCode','Temperature','VelocityDerivative',...
            'CollisionPartners','Weights','CollisionPartnerDensities','MoleculeDensity','CloudColumnDensity','BackgroundTemperature',...
            'CalculateIntensities','NumLevelsForSolution','FirstPopulationGuess','DebugIndicators'};
        
    end
    
    methods(Static)
        
        function [Names, Values] = GetClassConstants (CurrentClass)
            
            Names = {};
            Values = [];
            
            getMetaDataCommand = sprintf('?%s',CurrentClass);
            metaData = eval(getMetaDataCommand);
            
            for prop=1:numel(metaData.Properties)
                
                property = metaData.Properties{prop};
                
                if property.Constant
                    Names{end+1} = property.Name;
                    getConstantValueCommand = sprintf('%s.%s',CurrentClass,property.Name);
                    Values(end+1) = eval(getConstantValueCommand);
                end
            end
            
        end
        
        function Property = FindPropertyByName (Properties, PropertyName)
            
            for i=1:numel(Properties)
                if strcmpi(Properties(i).Name, PropertyName)
                    Property = Properties(i);
                    return;
                end
            end
        end
        
        function GUIRequest = ConvertRequestToGUIRequest (LVGRequest)
            
            GUIRequest = LVGSolverPopulationRequest.empty(0,1);
            
            for i=1:numel(LVGRequest)
                
                GUIRequest(i) = LVGRequest(i).Copy();
                
                %Run Type
                [runTypeNames,runTypeValues] = RequestPropertyGrid.GetClassConstants('RunTypeCodes');
                GUIRequest(i).RunTypeCode = runTypeNames{runTypeValues==GUIRequest(i).RunTypeCode};
                
                %Beta Type
                [betaTypeNames,betaTypeValues] = RequestPropertyGrid.GetClassConstants('BetaTypeCodes');
                GUIRequest(i).BetaTypeCode = betaTypeNames{betaTypeValues==GUIRequest(i).BetaTypeCode};
                
                %Collision partners & weights
                [collisionPartnerNames,collisionPartnerValues] = RequestPropertyGrid.GetClassConstants('CollisionPartnersCodes');
                
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
                [runTypeNames,runTypeValues] = RequestPropertyGrid.GetClassConstants('RunTypeCodes');
                LVGRequest(i).RunTypeCode = runTypeValues(strcmpi(runTypeNames,GUIRequest(i).RunTypeCode));
                
                %Beta Type
                [betaTypeNames,betaTypeValues] = RequestPropertyGrid.GetClassConstants('BetaTypeCodes');
                LVGRequest(i).BetaTypeCode = betaTypeValues(strcmpi(betaTypeNames,GUIRequest(i).BetaTypeCode));
                
                %Collision partners & weights
                [collisionPartnerNames,collisionPartnerValues] = RequestPropertyGrid.GetClassConstants('CollisionPartnersCodes');
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
            
            [runTypeNames,runTypeValues] = RequestPropertyGrid.GetClassConstants('RunTypeCodes');            
            prop =properties.FindByName('RunTypeCode');
            prop.Type = PropertyType('char', 'row', runTypeNames);
            
            [betaTypeNames,betaTypeValues] = RequestPropertyGrid.GetClassConstants('BetaTypeCodes');
            prop =properties.FindByName('BetaTypeCode');
            prop.Type = PropertyType('char', 'row', betaTypeNames);
            
            [collisionPartnerNames,collisionPartnerValues] = RequestPropertyGrid.GetClassConstants('CollisionPartnersCodes');
            prop =properties.FindByName('CollisionPartners');
            prop.Type = PropertyType('logical', 'row', collisionPartnerNames);

            prop =properties.FindByName('FirstPopulationGuess');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            prop.ReadOnly = false;

            prop =properties.FindByName('Weights');
            prop.Type = PropertyType('denserealdouble', 'matrix');
            
            prop =properties.FindByName('NumLevelsForSolution');
            prop.Type = PropertyType('denserealdouble', 'scalar');
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
        
        function ResetGripProperties(PropertyGridHandle)
            
            PropertyGridHandle.Item = [];
            
        end
        
    end
    
end

