library(grf)

f <- function(x) {
  10 * x[1] + 5 * x[2] + 2 * x[3]**2 + 2 * x[4]**3
}

n <- 600
p <- 5

results = sapply(1:100, function(i){
  print(i)
  
  X <- matrix(runif(n * p, 0, 1), n, p)
  MU <- apply(X, FUN = f, MARGIN = 1)
  Y <- MU + rnorm(n)
  
  ll.forest <- ll_regression_forest(X, Y, num.trees = 500, ll.splits = TRUE, ll.split.lambda = 0.1)
  preds.ll.splits.oob <- predict(ll.forest, linear.correction.variables = 1:p, ll.lambda = 0)
  
  forest = regression_forest(X, Y, num.trees = 500)
  
  mseg = mean((predict(forest, linear.correction.variables = 1:p, ll.lambda = 0)$predictions - MU)**2)
  msel = mean((preds.ll.splits.oob$predictions - MU)**2)
  
  msel/mseg < 0.9
})

sum(results)
