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