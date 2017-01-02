#include "ObservationsSerializer.h"
#include "utility.h"

void ObservationsSerializer::serialize(std::ostream& stream, Observations* observations) {
  size_t num_samples = observations->get_num_samples();
  stream.write((char*) &num_samples, sizeof(num_samples));

  auto observations_by_type = observations->get_observations_by_type();
  size_t num_types = observations_by_type.size();
  stream.write((char*) &num_types, sizeof(num_types));

  for (auto it = observations_by_type.begin(); it != observations_by_type.end(); it++) {
    std::string type = it->first;
    stream.write((char*) &type, sizeof(type));
    saveVector1D(it->second, stream);
  }
}

Observations* ObservationsSerializer::deserialize(std::istream& stream) {
  size_t num_samples;
  stream.read((char*) &num_samples, sizeof(num_samples));

  size_t num_types;
  stream.read((char*) &num_types, sizeof(num_types));

  std::unordered_map<std::string, std::vector<double>> observations_by_type;
  for (int i = 0; i < num_types; i++) {
    std::string type;
    stream.read((char*) &type, sizeof(type));

    std::vector<double> observations;
    readVector1D(observations, stream);
    observations_by_type[type] = observations;
  }

  return new Observations(observations_by_type, num_samples);
}