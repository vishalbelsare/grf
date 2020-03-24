/*-------------------------------------------------------------------------------
  This file is part of generalized random forest (grf).

  grf is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  grf is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with grf. If not, see <http://www.gnu.org/licenses/>.
 #-------------------------------------------------------------------------------*/

#include "commons/utility.h"
#include "relabeling/RegressionDiscontinuityRelabelingStrategy.h"

namespace grf {

RegressionDiscontinuityRelabelingStrategy::RegressionDiscontinuityRelabelingStrategy():
  reduced_form_weight(0) {}

RegressionDiscontinuityRelabelingStrategy::RegressionDiscontinuityRelabelingStrategy(double reduced_form_weight):
  reduced_form_weight(reduced_form_weight) {}

bool RegressionDiscontinuityRelabelingStrategy::relabel(
    const std::vector<size_t>& samples,
    const Data& data,
    std::vector<double>& responses_by_sample) const {

  // Prepare the relevant averages.
  size_t num_samples = samples.size();

  double total_outcome = 0.0;
  double total_treatment = 0.0;
  double total_running_variable = 0.0;

  for (size_t sample : samples) {
    total_outcome += data.get_outcome(sample);
    total_treatment += data.get_treatment(sample);
    total_running_variable += data.get_instrument(sample);
  }

  double average_outcome = total_outcome / num_samples;
  double average_treatment = total_treatment / num_samples;
  double average_running_variable = total_running_variable / num_samples;
  double average_regularized_running_variable = (1 - reduced_form_weight) * average_running_variable
                                          + reduced_form_weight * average_treatment;

  // Calculate the treatment effect.
  double numerator = 0.0;
  double denominator = 0.0;

  for (size_t sample : samples) {
    double outcome = data.get_outcome(sample);
    double treatment = data.get_treatment(sample);
    double running_variable = data.get_instrument(sample);
    double regularized_running_variable = (1 - reduced_form_weight) * running_variable
                                    + reduced_form_weight * treatment;

    numerator += (regularized_running_variable - average_regularized_running_variable) * (outcome - average_outcome);
    denominator += (regularized_running_variable - average_regularized_running_variable) * (treatment - average_treatment);
  }

  if (equal_doubles(denominator, 0.0, 1.0e-10)) {
    return true;
  }

  double local_average_treatment_effect = numerator / denominator;

  // Create the new outcomes.
  for (size_t sample : samples) {
    double response = data.get_outcome(sample);
    double treatment = data.get_treatment(sample);
    double running_variable = data.get_instrument(sample);
    double regularized_running_variable = (1 - reduced_form_weight) * running_variable + reduced_form_weight * treatment;

    double residual = (response - average_outcome) - local_average_treatment_effect * (treatment - average_treatment);
    responses_by_sample[sample] = (regularized_running_variable - average_regularized_running_variable) * residual;
  }
  return false;
}

} // namespace grf
