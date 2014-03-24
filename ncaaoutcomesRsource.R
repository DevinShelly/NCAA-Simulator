library("Hmisc")
outcomes = read.csv("ncaaoutcomes.csv")[1]
Ecdf(outcomes[,1], xlim = c(0, hdquantile(outcomes[,1], .99)), main = "ECDF Kenpom", xlab = "Perfect Bracket Odds (1/x)", subtitles=FALSE)

smallIncrement = 0.000001
largeIncrement = 0.0001
x = c(seq(0, 0.01-smallIncrement, smallIncrement), seq(0.01, 0.99, largeIncrement))
quantiles = quantile(outcomes[,1], x, names=FALSE)
sumBrackets = seq(1:length(x))

index = 1
for (i in x)
{
  increment = x[index+1]-x[index]
  firstQuantile = quantiles[index]
  secondQuantile = quantiles[index+1]
  averageQuantile = (firstQuantile+secondQuantile)/2.0
  decimalProbability = 1.0/averageQuantile
  numBracketsBetweenQuantiles = increment/decimalProbability
  if (index==1)
  {
    sumBrackets[index] = numBracketsBetweenQuantiles
  }
  else
  {
   sumBrackets[index] = numBracketsBetweenQuantiles + sumBrackets[index-1]
  }
  
  if (index%%1000==0)
  {
    print(x[index])
  }
  index = index+1
}

x = c(seq(0, 0.01-smallIncrement, smallIncrement), seq(0.01, 0.99, largeIncrement))
y = sumBrackets[1:length(x)]
plot(x=x, y = y, type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')
x = c(seq(0, 0.01-smallIncrement, smallIncrement), seq(0.01, 0.5, largeIncrement))
y = sumBrackets[1:length(x)]
plot(x=x, y = y, type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')
x = seq(0, 0.01, smallIncrement)
y = sumBrackets[1:length(x)]
plot(x=x, y = y, type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')
x = seq(0, 0.0002, smallIncrement)
y = sumBrackets[1:length(x)]
plot(x=x, y = y, type='l', main = 'Bracket Percentiles', ylab = 'Number of Brackets', xlab = 'Percentiles')
