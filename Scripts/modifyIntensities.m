result = LVGResults.Get('CO-LVG-Varying Nh2/dvdr Ratio=e-4');
modifiedResult = IntensitiesHelper.PinColumnDensityToProperty(LVGParameterCodes.MoleculeAbundanceRatio, result.OriginalRequest.MoleculeAbundanceRatios, result);
LVGResults.Put('CO-LVG-Varying Nh2/dvdr Ratio=e-4 - Modified', modifiedResult);

result = LVGResults.Get('HCN-LVG-Varying Nh2/dvdr Ratio=e-4');
modifiedResult = IntensitiesHelper.PinColumnDensityToProperty(LVGParameterCodes.MoleculeAbundanceRatio, result.OriginalRequest.MoleculeAbundanceRatios, result);
LVGResults.Put('HCN-LVG-Varying Nh2/dvdr Ratio=e-4 - Modified', modifiedResult);