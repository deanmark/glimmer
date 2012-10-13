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

classdef WorkspaceHelper
    
    properties(Constant)
       
        ws = 'base';
        MoleculesVariableName = 'Molecules';
        ResultsVariableName = 'LVGResults';
        RequestsVariableName = 'LVGRequests';
        
    end
    
    methods(Static=true)
        
        function MoleculesHash = GetMoleculesHashFromWorkspace ()
            
            moleculesVariableExists = ~isempty(evalin(WorkspaceHelper.ws, sprintf('who(''%s'')', WorkspaceHelper.MoleculesVariableName)));
            
            if moleculesVariableExists
                [MoleculesHash] = evalin(WorkspaceHelper.ws, WorkspaceHelper.MoleculesVariableName);
            else
                MoleculesHash = Hashtable();
                assignin(WorkspaceHelper.ws, WorkspaceHelper.MoleculesVariableName, MoleculesHash);
            end
            
        end
        
        function Molecule = GetMoleculeDataFromWorkspace (MoleculeIdentifier)
            
            Molecules = WorkspaceHelper.GetMoleculesHashFromWorkspace();
            Molecule = Molecules.Get(MoleculeIdentifier);
            
        end
        
        function LVGResultsHash = GetLVGResultsHashFromWorkspace()
            
            resultsVariableExists = ~isempty(evalin(WorkspaceHelper.ws, sprintf('who(''%s'')', WorkspaceHelper.ResultsVariableName)));
            
            if resultsVariableExists
                [LVGResultsHash] = evalin(WorkspaceHelper.ws, WorkspaceHelper.ResultsVariableName);
            else
                LVGResultsHash = Hashtable();
                assignin(WorkspaceHelper.ws, WorkspaceHelper.ResultsVariableName, LVGResultsHash);
            end
            
        end
        
        function LVGResult = GetLVGResultFromWorkspace (ResultIdentifier)
            
            Hash = WorkspaceHelper.GetLVGResultsHashFromWorkspace();
            LVGResult = Hash.Get(ResultIdentifier);
            
        end
   
        function Requests = GetLVGRequestsListFromWorkspace ()
            
            resultsVariableExists = ~isempty(evalin(WorkspaceHelper.ws, sprintf('who(''%s'')', WorkspaceHelper.RequestsVariableName)));
            
            if resultsVariableExists
                Requests = evalin(WorkspaceHelper.ws, WorkspaceHelper.RequestsVariableName);
            else
                Requests = LVGSolverPopulationRequest.empty(1,0);
                assignin(WorkspaceHelper.ws, WorkspaceHelper.RequestsVariableName, Requests);
            end
            
        end
        
        function SetLVGRequestsListInWorkspace (Requests)
            
            assignin(WorkspaceHelper.ws, WorkspaceHelper.RequestsVariableName, Requests);
            
        end
        
    end
    
end
