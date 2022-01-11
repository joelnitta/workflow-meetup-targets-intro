library(targets)
library(tarchetypes)
# This is an example _targets.R file. Every
# {targets} pipeline needs one.
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.

# Define custom functions and other global objects.
# This is where you write source(\"R/functions.R\")
# if you keep your functions in external scripts.
summ <- function(dataset) {
  summarize(dataset, mean_x = mean(x))
}

get_corr <- function(dataset) {
	mod <- lm(x ~ y, dataset)
	broom::tidy(mod) |>
		mutate(name = unique(dataset$name))
}

# Set target-specific options such as packages.
tar_option_set(packages = c("dplyr", "tibble"))

# End this file with a list of target objects.
tar_plan(
	x_start = rep(100, 3),
	y_start = rep(100, 3),
	dataset_name = 1:3,
  tar_target(
  	data,
  	tibble(x = sample.int(x_start), y = sample.int(y_start), name = dataset_name),
  	pattern = map(x_start, y_start, dataset_name)
  	),
	tar_target(
		model,
		get_corr(data),
		pattern = map(data)
	),
  tar_target(summary, summ(data)),
  tar_render(
  	report,
  	"report.Rmd"
  ),
	tar_target(x, seq_len(2)),
	tar_target(y, head(letters, 2)),
	tar_target(dynamic, tibble(x = x, y = y), pattern = map(x, y)) # 2 branches
)
