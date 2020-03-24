library(grf)

n <- 800
p <- 5
X <- matrix(rnorm(n * p), n, p)
W <- rbinom(n, 1, 0.5)
Y <- W * X[,1] + rnorm(n)
forest <- causal_forest(X, Y, W, clusters = c(rep(1, 200), rep(2, 200), rep(3, 400)))

#best_linear_projection(forest, X[,1:2], subset = 1:200)

average_partial_effect(forest, subset = (forest$clusters == 1))