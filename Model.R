

## MACHINE LEARNING PROJECT
## MODELING SCRIPT


# Setup -------------------------------------------------------------------


# Vector of essential packages
packages <- c('caret', 'tm', 'e1071', 'lubridate')
# Loop through each element,
for(package in packages) {
  # Install the package if needed
  if(!package %in% installed.packages()[,1]) {
    install.packages(package)
  }
  # Load the package
  library(package, character.only = TRUE)
}

rm(package, packages)

# Load data
load(file = 'raw.Rdata')
# data$p: data.frame of predictors
# data$c: data.frame of categories

# Select question as text and tag1 as tag
data <- data.frame(
  text = raw$p$question,
  tag = raw$c$tag1
)


# Pre-Process -------------------------------------------------------------


# Remove punctuation
# Note: Replace with ' ' instead of ''
# Side-Product: Extra whitespace
data$text <- stri_replace_all(str = data$text, regex = '[[:punct:]]', replacement = ' ')

# Remove edge whitespace
data$text <- stri_replace_all(str = x, regex = '^[[:space:]]+ | [[:space:]]+$', replacement = '')





# # Randomly select 70% of data from each TagPost
# i <- lapply(X = unique(dat$TagPost), FUN = function(x) {
#   x <- which(dat$TagPost == x)
#   sample(x = x, size = 0.7 * length(x))
# })
# i <- unlist(i)
# 
# # Training data
# train <- VCorpus(VectorSource(dat[i,'Question']))
# # Create a document term matrix.
# train <- DocumentTermMatrix(train, control = list(
#   removePunctuation = TRUE,
#   stemming = TRUE,
#   stopwords = TRUE,
#   wordLengths = c(3,10)
# ))
# # Created weight document term matrx
# train.wt <- weightTfIdf(train)
# 
# # Convert to data frame
# train <- as.matrix(train)
# train <- as.data.frame(train)
# train.wt <- as.matrix(train.wt)
# train.wt <- as.data.frame(train.wt)
# # Assign class
# train.wt$TagPost <- train$TagPost <- as.factor(dat[i,'TagPost'])
# 
# # Train
# fit <- train(TagPost ~ ., data = train, method = 'bayesglm')
# fit.wt <- train(TagPost ~ ., data = train.wt, method = 'bayesglm')
# 
# # Check accuracy on training.
# predict(fit, newdata = train)
# 
# # Test data.
# corpus <- VCorpus(VectorSource(dat[-i,'Question']))
# 
# tdm <- DocumentTermMatrix(corpus, control = list(dictionary = Terms(train), removePunctuation = TRUE, stemming = TRUE))
# test <- as.matrix(tdm)
# 
# # Check accuracy on test.
# predict(fit, newdata = test)