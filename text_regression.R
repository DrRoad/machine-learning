
rm(list = ls())
library(tidyverse)
library(tm)
library(Matrix)
library(glmnet)

# INPUT
# text            character vector containing the documents for analysis.
# y               numeric vector of outputs associated with the documents.
# n.splits        How many resampling steps should be used to set lambda?
# size            How much of the data should be used during resampling for model fitting?
# standardizeCase Should all of the text be standardized on lowercase?
# stripSpace      Should all whitespace be stripped from the text?
# removeStopwords Should tm's list of English stopwords be pulled out of the text?

# OUTPUT
# li()
#   regression coefficients
#   terms used with those coefficients
#   lambda used for model assessment
#   estimate of the RMSE associated with that model

data <- list(
  train = read.csv('siop_ml_train_participant.csv', stringsAsFactors = FALSE) %>%
    transmute(
      doc_id = as.character(Respondent_ID),
      text  = as.character(open_ended_1),
      y  = as.numeric(E_Scale_score)
    ),
  test  = read.csv('siop_ml_dev_participant.csv', stringsAsFactors = FALSE) %>%
    transmute(
      doc_id = as.character(Respondent_ID),
      text  = as.character(open_ended_1)
    )
)

# Generate and preprocess the corpus
corpus <- Corpus(DataframeSource(data$train)) %>%
  tm_map(tolower) %>%
  tm_map(stripWhitespace) %>%
  tm_map(removeWords, stopwords('english'))

# Generate a document term matrix
dtm <- DocumentTermMatrix(corpus)

# Generate a sparse matrix based on the dtm
x <- Matrix(data = 0, nrow = dtm$nrow, ncol = dtm$ncol, sparse = TRUE)
for(i in 1:length(dtm$i)) {
  x[dtm$i[i], dtm$j[i]] <- dtm$v[i]
}

y <- data$train$y

reg_fit <- glmnet(x, y)

lambdas <- reg_fit$lambda

performance <- data.frame()

# Calculate number of splits based on time required to perform original model fit.
# Or based on data set size?
# num. splits: 10
splits <- 10
# size: proportion of training set
size <- 0.8

for (i in 1:splits) {
  # Create train/test sets
  ix <- sample(1:nrow(x), round(size * nrow(x)))
  training.x <- x[ix, ]
  training.y <- y[ix]
  test.x <- x[-ix, ]
  test.y <- y[-ix]

  for (il in 1:length(lambdas)) {
    lambda <- lambdas[il]
    resampling.fit <- glmnet(training.x, training.y)
    predicted.y <- as.numeric(predict(resampling.fit, newx = test.x, s = lambda))
    rmse <- sqrt(mean((predicted.y - test.y) ^ 2))
    performance <- rbind(performance, data.frame(Split = i, Lambda = lambda, RMSE = rmse))
    writeLines(paste0('  ', round(il / length(lambdas) * 100, 0), '%'))
  }
  writeLines(paste0(round(i / splits * 100, 0), '%'))
}

mean.rmse <- performance %>%
  group_by(Lambda) %>%
  summarise(
    RMSE = mean(RMSE, na.rm = TRUE)
  )

lambda_optimal <- mean.rmse %>%
  filter(RMSE == min(RMSE)) %>%
  select(Lambda) %>%
  max()

rmse_optimal <- mean.rmse %>%
  filter(Lambda == lambda_optimal) %>%
  select(RMSE) %>%
  max()

coefficients <- as.numeric(coef(regularized.fit, s = lambda_optimal)[, 1])
terms <- c('(Intercept)', colnames(dtm))

output <- list(
  coefficients = coefficients,
  terms        = terms,
  lambda       = lambda_optimal,
  rmse         = rmse_optimal
)

