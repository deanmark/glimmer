result1 = LVGResults.Get('PACS middle - LVG');
result2 = LVGResults.Get('PACS middle - LTE');

% result1 = LVGResults.Get('PACS high - LVG');
% result2 = LVGResults.Get('PACS high - LTE');


%(DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, FileName)
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Population, result1, [1], [1], [1], [1], 'OpenNew','');
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Population, result2, [1], [1], [1], [1], 'Add','');