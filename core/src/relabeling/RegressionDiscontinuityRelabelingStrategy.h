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

#ifndef GRF_REGRESSIONDISCONTINUITYRELABELINGSTRATEGY_H
#define GRF_REGRESSIONDISCONTINUITYRELABELINGSTRATEGY_H

#include <vector>

#include "commons/Data.h"
#include "relabeling/RelabelingStrategy.h"
#include "tree/Tree.h"

namespace grf {

class RegressionDiscontinuityRelabelingStrategy final: public RelabelingStrategy {
public:
  RegressionDiscontinuityRelabelingStrategy();

  RegressionDiscontinuityRelabelingStrategy(double reduced_form_weight);

  bool relabel(
      const std::vector<size_t>& samples,
      const Data& data,
      std::vector<double>& responses_by_sample) const;

  DISALLOW_COPY_AND_ASSIGN(RegressionDiscontinuityRelabelingStrategy);

private:
  double reduced_form_weight;
};

} // namespace grf

#endif //GRF_REGRESSIONDISCONTINUITYRELABELINGSTRATEGY_H
