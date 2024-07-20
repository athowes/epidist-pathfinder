library(devtools)

devtools::install_github("epinowcast/epidist")

library(epidist)

set.seed(1)

meanlog <- 1.8
sdlog <- 0.5
obs_time <- 25
sample_size <- 200

obs_cens_trunc <- simulate_gillespie(seed = 101) |>
  simulate_secondary(
    meanlog = meanlog,
    sdlog = sdlog
  ) |>
  observe_process() |>
  filter_obs_by_obs_time(obs_time = obs_time)

obs_cens_trunc_samp <-
  obs_cens_trunc[sample(seq_len(.N), sample_size, replace = FALSE)]

data <- as_latent_individual(obs_cens_trunc_samp)

fit_hmc <- epidist(data = data, algorithm = "sampling", seed = 1)
fit_laplace <- epidist(data = data, algorithm = "laplace", draws = 4000, seed = 1)
fit_advi <- epidist(data = data, algorithm = "meanfield", draws = 4000, seed = 1)
fit_pathfinder <- epidist(
  data = data, algorithm = "pathfinder", draws = 4000, num_paths = 4, seed = 1
)

standata <- epidist(data = data, fn = brms::make_standata)
saveRDS(standata, "standata.rds")

stancode <- epidist(data = data, fn = brms::make_stancode)
saveRDS(stancode, "stancode.rds")
