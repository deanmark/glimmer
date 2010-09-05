classdef WorkspaceHelper
    
    methods(Static=true)
        
        function MoleculesHash = GetMoleculesHashFromWorkspace ()
            
            ws = 'base';
            moleculesVariableName = 'Molecules';
            
            moleculesVariableExists = ~isempty(evalin(ws, sprintf('who(''%s'')', moleculesVariableName)));
            
            if moleculesVariableExists
                [MoleculesHash] = evalin(ws, moleculesVariableName);
            else
                MoleculesHash = Hashtable();
                assignin(ws, moleculesVariableName, MoleculesHash);
            end
            
        end
        
        function Molecule = GetMoleculeDataFromWorkspace (MoleculeIdentifier)
            
            Molecules = WorkspaceHelper.GetMoleculesHashFromWorkspace();
            Molecule = Molecules.Get(MoleculeIdentifier);
            
        end
        
        function LVGResultsHash = GetLVGResultsHashFromWorkspace()
            
            ws = 'base';
            resultsVariableName = 'LVGResults';
            
            resultsVariableExists = ~isempty(evalin(ws, sprintf('who(''%s'')', resultsVariableName)));
            
            if resultsVariableExists
                [LVGResultsHash] = evalin(ws, resultsVariableName);
            else
                LVGResultsHash = Hashtable();
                assignin(ws, resultsVariableName, LVGResultsHash);
            end
            
        end
        
        function LVGResult = GetLVGResultFromWorkspace (ResultIdentifier)
            
            Hash = WorkspaceHelper.GetLVGResultsHashFromWorkspace();
            LVGResult = Hash.Get(ResultIdentifier);
            
        end
        
    end
    
end