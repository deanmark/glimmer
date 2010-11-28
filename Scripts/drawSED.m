result1 = LVGResults.Get('Low component - LTE reference');
result2 = LVGResults.Get('PACS LVG');

% result1 = LVGResults.Get('PACS high - LVG');
% result2 = LVGResults.Get('PACS high - LTE');


%(DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, FileName)
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Population, result2, [1], [8], [1:20], [1], 'OpenNew','');
%Scripts.DrawResults1Molecule(ComparisonTypeCodes.Population, result2, [1], [7], [10], [1], 'Add','');