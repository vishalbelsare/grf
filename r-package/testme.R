rm(list = ls())

library(grf)
library(ggplot2)
library(glmnet)

setwd("~/Dropbox/Local Linear Forests/high_dim/figures")

p = 30
sigma = 5

f = function(x){ 10*sin(pi*x[1]*x[2]) + 20*((x[3] - 0.5)**2) + 10*x[4] + 5*x[5] } 

n.train = 1e6
X = matrix(runif(n.train*p, 0, 1), nrow = n.train, ncol = p)
Y = apply(X, MARGIN = 1, FUN = f) + sigma * rnorm(n.train)

ptm = proc.time()
forest = regression_forest(X, Y, tune.parameters = "none", num.trees = 50)
time.train = (proc.time() - ptm)[[3]]
cat(paste("Training time was", round(time.train, 3), "seconds"))

n.tests = c(5e3, 1e4, 5e4, 1e5)

results = data.frame(t(sapply(n.tests, function(n.test){
  print(paste("at step", which(n.tests == n.test), "out of", length(n.tests)))
  
  X.test = matrix(runif(n.test*p, 0, 1), nrow = n.test, ncol = p)
  truth = apply(X.test, MARGIN = 1, FUN = f) 
  
  ptm = proc.time()
  preds = predict(forest, X.test)
  time.predict.grf = (proc.time() - ptm)[[3]]
  
  ptm = proc.time()
  preds.llf = predict(forest, X.test, linear.correction.variables = 1, ll.lambda = 0.01)
  time.predict.llf = (proc.time() - ptm)[[3]]
  
  ptm = proc.time()
  llforest = ll_regression_forest(X, Y, enable.ll.split = TRUE, tune.parameters = "none", num.trees = 50)
  preds.llf = predict(llforest, X.test, linear.correction.variables = 1, ll.lambda = 0.01)
  time.predict.llf.split = (proc.time() - ptm)[[3]]
  ptm = proc.time()
  
  c(time.train + time.predict.grf, time.train + time.predict.llf, time.predict.llf.split)
})))

colnames(results) = c("time.grf", "time.llf", "time.llf.split")
results$n.test = n.tests

results$time.grf = log(results$time.grf + 1)
results$time.llf = log(results$time.llf + 1)
results$time.llf.split = log(results$time.llf.split + 1)

ggplot(results, aes(x = log(n.test), y = time.grf, color = "grf")) + geom_line(aes(color = "grf"), lwd = 2) + geom_point() + theme_bw() + 
  geom_line(aes(x = log(n.test), y = time.llf, color = "llf"), lwd = 2) + 
  geom_point(aes(x = log(n.test), y = time.llf, color = "llf")) + 
  geom_line(aes(x = log(n.test), y = time.llf.split, color = "llf.split"), lwd = 2) + 
  geom_point(aes(x = log(n.test), y = time.llf.split, color = "llf.split")) + 
  ylab("Log(time in seconds)") + 
  labs(fill = "Method") +
  theme(axis.text = element_text(size = 20),
        legend.text = element_text(size = 20),
        legend.title = element_text(size = 20),
        axis.title = element_text(size = 20))
ggsave("train1e6_split.jpeg")
