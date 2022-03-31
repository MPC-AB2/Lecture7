path = 'V:\mpc\ab2\Lecture7\Cats';

[segmentation] = prvni(path);

[segmResults] = Eval_Segmentation(segmentation);

str_e = sprintf('DICE: %0.5f, std: %0.5f', segmResults.meanDice, segmResults.stdDice);

disp(str_e)
disp(segmResults.Dice)