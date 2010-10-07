result = LVGResults.Get('12CO Basic');

%(PopulationResult, VelocityDerivativeIndices, TemperatureIndices, CollisionPartnerDensitiesIndices)
Scripts.DrawResults1Molecule(ComparisonTypeCodes.Population, result, 1:5, [1], [1]);