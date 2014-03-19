outcomes = read.csv("ncaaoutcomes.csv")[1]
ecdf = ecdf(outcomes[,1])
plot(ecdf, xlim = c(quantile(ecdf, probs=0), quantile(ecdf, probs=0.99)), main = "ECDF Kenpom", xlab = "Perfect Bracket Odds (1/x)")

increment = 0.001
top99seq = seq(0, 0.998, increment)
numBrackets = seq(1:length(top99seq))

for (i in seq(0, .998, increment))
{
  firstQuantile = quantile(ecdf, probs = i, name = FALSE)
  secondQuantile = quantile(ecdf, probs = i + increment, name = FALSE)
  averageQuantile = (firstQuantile+secondQuantile)/2.0
  decimalProbability = 1.0/averageQuantile
  numBracketsBetweenQuantiles = increment/decimalProbability
  numBrackets[(i+increment)/increment] = numBracketsBetweenQuantiles
}

sumBrackets = numBrackets
for (i in 2:length(numBrackets))
{
  sumBrackets[i] = sumBrackets[i] +  sumBrackets[i-1]
}

plot(x=seq(0, .998, increment), y = sumBrackets, type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')
plot(x=seq(0, .5, increment), y = sumBrackets[1:501], type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')
plot(x=seq(0, .01, increment), y = sumBrackets[1:11], type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')

#take smaller steps to zoom in at the very far left edge
increment = 0.00001;
top0002 = seq(0, 0.0002, increment)
numBrackets = seq(1:length(top0002))

for (i in top0002)
{
  firstQuantile = quantile(ecdf, probs = i, name = FALSE)
  secondQuantile = quantile(ecdf, probs = i + increment, name = FALSE)
  averageQuantile = (firstQuantile+secondQuantile)/2.0
  decimalProbability = 1.0/averageQuantile
  numBracketsBetweenQuantiles = increment/decimalProbability
  numBrackets[(i+increment)/increment] = numBracketsBetweenQuantiles
}

sumBrackets = numBrackets
for (i in 2:length(numBrackets))
{
  sumBrackets[i] = sumBrackets[i] +  sumBrackets[i-1]
}

plot(x=top0002, y = sumBrackets, type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')