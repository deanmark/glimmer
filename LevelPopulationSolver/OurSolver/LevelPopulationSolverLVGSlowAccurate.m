classdef LevelPopulationSolverLVGSlowAccurate < LevelPopulationSolverLVG
    
    properties(SetAccess = private)
        
        m_lastChangedIteration;
        
    end
    
    methods(Access=public)
       
        function LVG = LevelPopulationSolverLVGSlowAccurate(MoleculeData, BetaProvider, LVGAlgorithmParameters)
            
            LVG@LevelPopulationSolverLVG(MoleculeData, BetaProvider, LVGAlgorithmParameters);
            
        end
        
    end
    
    methods(Access=protected)
        
        function PopulationGuess = interpolateNextPopulation (obj, CurrentPopulationGuess, PopulationHistory, CurrentIteration)
        
%             if isempty(obj.m_lastChangedIteration)
%                 obj.m_lastChangedIteration = 1;
%             end               
%                 
%             step = 30;
%             
%             if CurrentIteration > (600 + obj.m_lastChangedIteration) &&  mod(CurrentIteration,step)==0
%                 
%                 lastAvg = mean(PopulationHistory(:,(CurrentIteration-step*2):(CurrentIteration-step*1)),2);
%                 currAvg = mean(PopulationHistory(:,(CurrentIteration-step*1):(CurrentIteration-step*0)),2);
%                 
%                 diff = max(Scripts.PopulationDiff(currAvg,lastAvg));
%                 
%                 if diff<0.05
%                    
%                     obj.m_algorithmParameters.ChangePercent = obj.m_algorithmParameters.ChangePercent/10;
%                     obj.m_lastChangedIteration = CurrentIteration;
%                     PopulationGuess = currAvg;
%                     return;
%                     
%                 end
% 
%             end
            
            PopulationGuess = CurrentPopulationGuess;
            
        end
        
        function BetaGuess = interpolateNextBeta (obj, CurrentBetaGuess, BetaHistory, CurrentIteration)
            
            if (CurrentIteration > 1)
                BetaGuess = BetaHistory(:,:,CurrentIteration-1)*(1-obj.m_algorithmParameters.ChangePercent) + CurrentBetaGuess*obj.m_algorithmParameters.ChangePercent;
            else
                BetaGuess = CurrentBetaGuess;
            end
            
        end
        
    end
    
end