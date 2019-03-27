
# GloVe embeddings
rm(list = ls())
library(text2vec)
# word2vec word vectors capture many linguistic regularities
# e.g., take word vectors for the words “paris,” “france,” and “germany” and perform the following operation:
# vector("paris") − vector("france") + vector("germany")
# ==> resulting vector will be close to the vector for “rome”

# Download wikipedia data
wiki <- readLines('text8', n = 1, warn = FALSE)

# Create a vocabulary
#   a set of words for which we want to learn word vectors
# Note: all text2vec functions which operate on raw text data
#   (create_vocabulary, create_corpus, create_dtm, create_tcm)
#   have a streaming API. Must iterate over tokens as the first argument for these functions
# Create iterator over tokens
tokens <- space_tokenizer(wiki)

# Create vocabulary. Terms will be unigrams (simple words)
it <- itoken(tokens, progressbar = FALSE)
vocab <- create_vocabulary(it)

# These words should not be too uncommon
# (Can't calculate a meaningful word vector for a word appearing only once!)
# Take only words which appear at least five times
# text2vec provides additional options to filter vocabulary
vocab <- prune_vocabulary(vocab, term_count_min = 5L)

# 71290 terms in the vocabulary
# Ready to construct term-co-occurence matrix (TCM)

# Use filtered vocabulary
vectorizer <- vocab_vectorizer(vocab)

# use window of 5 for context words
tcm <- create_tcm(it, vectorizer, skip_grams_window = 5L)

# Now we have a TCM matrix
# We will factorize it via the GloVe algorithm
# text2vec uses a parallel stochastic gradient descent algorithm
# By default it will use all cores on your machine
# e.g., to use 4 threads call RcppParallel::setThreadOptions(numThreads = 4)

glove <- GlobalVectors$new(word_vectors_size = 50, vocabulary = vocab, x_max = 10)
wv_main <- glove$fit_transform(x = tcm, n_iter = 10, convergence_tol = 0.01)

# Alternatively we can train model with R’s S3 interface
# but keep in mind that all text2vec models are R6 classes and they are mutable!
# So fit, fit_transform methods modify models
# glove = GlobalVectors$new(word_vectors_size = 50, vocabulary = vocab, x_max = 10)
# `glove` object will be modified by `fit_transform()` call !
# wv_main = fit_transform(tcm, glove, n_iter = 20)

# model learns two sets of word vectors, viz., main and context
# Essentially the same bc model is symmetric
# Usually, learning two sets of word vectors leads to higher quality embeddings
# GloVe model is “decomposition” model (inherits from mlapiDecomposition - generic class of models which decompose input matrix into two low-rank matrices)
# So on par with any other mlapiDecomposition model second low-rank matrix (context word vectors) is available in components field:
wv_context <- glove$components
# Note: as in all models which inherit from mlapiDecomposition transformed matrix will has nrow = nrow(input),  ncol = rank and second component matrix will has nrow = rank, ncol = ncol(input)

# While both of word-vectors matrices can be used as result it usually better (idea from GloVe paper) to average or take a sum of main and context vector
word_vectors <- wv_main + t(wv_context)

# We can find the closest word vectors for our paris - france + germany example:
a <- word_vectors["paris", , drop = FALSE]
b <- word_vectors["france", , drop = FALSE]
c <- word_vectors["germany", , drop = FALSE]
berlin <- a - b + c
cos_sim <- sim2(x = word_vectors, y = berlin, method = "cosine", norm = "l2")
head(sort(cos_sim[,1], decreasing = TRUE), 5)
