library(grf)

causal_data <- read.table("~/Github/grf/core/test/forest/resources/causal_data_ll.csv", quote="\"", comment.char="")
data = data.frame(causal_data)
X = data[,1:10]
Y = data[,11]
W = data[,12]
n = nrow(X)

results = sapply(1:10, function(rep){
  
  forest = causal_forest(X, Y, W)
  preds = predict(forest, linear.correction.variables = 3, ll.lambda = 0.1)$predictions
  
  Y = Y + 1
  shifted_forest = causal_forest(X, Y, W)
  shifted_preds = predict(shifted_forest, linear.correction.variables = 3, ll.lambda = 0.1)$predictions
  
  delta = 0
  for(i in 1:n){
    difference = shifted_preds[i] - preds[i]
    delta = delta + difference
  }
  
  delta/n
})

mean(results < 1e-1)
results

#TEST_CASE("LLF predictions vary linearly with Y", "[local linear], [forest]") {
#  uint outcome_index = 10;
#  Data* data = load_data("test/forest/resources/small_gaussian_data.csv");
#  data->set_outcome_index(outcome_index);
  
#  std::vector<size_t> linear_correction_variables = {1, 4, 7};
#  std::vector<double> lambda = {0.1};
  
#  // Run the original forest.
#  ForestTrainer trainer = ForestTrainers::regression_trainer();
#  ForestOptions options = ForestTestUtilities::default_honest_options();
#  Forest forest = trainer.train(data, options);
  
#  uint num_threads = 1;
#  size_t ci_group_size = 1;
  
 # ForestPredictor predictor = ForestPredictors::ll_regression_predictor(num_threads,
#                                                                        lambda, false, linear_correction_variables);
  
#  std::vector<Prediction> predictions = predictor.predict_oob(forest, data, false);
  
#  // Shift each outcome by 1, and re-run the forest.
#  bool error;
#  for (size_t r = 0; r < data->get_num_rows(); r++) {
#    double outcome = data->get(r, outcome_index);
#    data->set(outcome_index, r, outcome + 1, error);
#  }
  
#  Forest shifted_forest = trainer.train(data, options);
#  ForestPredictor shifted_predictor = ForestPredictors::ll_regression_predictor(num_threads,
#                                                                                lambda, false, linear_correction_variables);
#  std::vector<Prediction> shifted_predictions = shifted_predictor.predict_oob(shifted_forest, data, false);
  
 # REQUIRE(predictions.size() == shifted_predictions.size());
#  double delta = 0.0;
 # for (size_t i = 0; i < predictions.size(); i++) {
 #   Prediction prediction = predictions[i];
#    Prediction shifted_prediction = shifted_predictions[i];
    
#    double value = prediction.get_predictions()[0];
#    double shifted_value = shifted_prediction.get_predictions()[0];
    
 #   delta += shifted_value - value;
#  }
  
#  REQUIRE(equal_doubles(delta / predictions.size(), 1, 1e-1));
#  delete data;
#}