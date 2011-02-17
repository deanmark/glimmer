result1 = LVGResults.Get('Low component - LTE reference');
result2 = LVGResults.Get('PACS LVG');

% result1 = LVGResults.Get('PACS high - LVG');
% result2 = LVGResults.Get('PACS high - LTE');


%(DrawType, PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices, FileName)
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Intensities, result1, [1], [13], [1], [1], 'OpenNew','');
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Intensities, result2, [1], [13], [1], [1], 'Add','');