library(telegram.bot)
library(ggplot2)
library(httr)


source('config.R')


if (file_test('-f', ENV_PATH)) {
  readRenviron(ENV_PATH)
}


encode_text <- function(text) {
  "Accesses API that encodes the text"
  response <- POST(INCODE_API_URL,
                   body = text)
  json_data <- content(response, as = 'parsed')
  return(json_data)
}

build_dataframe <- function(words, codes) {
  "Build a dataframe of words and their 2d codes"
  num_codes <- length(codes)
  codes_matrix <- matrix(data = unlist(codes), 
                         nrow = num_codes, byrow = TRUE)
  
  res.pca <- prcomp(x = codes_matrix, rank = 2)
  
  reduced_codes <- res.pca$x
  colnames(reduced_codes) <- c('X', 'Y')
  
  encoded_words <- data.frame(reduced_codes)
  encoded_words$W <- words
  
  return(encoded_words)
}

compute_limits <- function(encoded_words) {
  "Computes limits of axes"
  xmin <- min(encoded_words$X)
  xmax <- max(encoded_words$X)
  ymin <- min(encoded_words$Y)
  ymax <- max(encoded_words$Y)
  
  width <- 1e-3 + xmax - xmin
  height <- 1e-3 + ymax - ymin
  
  xlims <- c(xmin - width * PLOT_LIMITS_MARGIN_COEF, 
             xmax + width * PLOT_LIMITS_MARGIN_COEF)
  ylims <- c(ymin - height * PLOT_LIMITS_MARGIN_COEF, 
             ymax + height * PLOT_LIMITS_MARGIN_COEF)
  
  lims = list(x=xlims, y=ylims)
  
  return(lims)
}

save_image <- function(name, encoded_words) {
  "Plots and saves to a file the given dataframe of words an their codes"
  
  lims <- compute_limits(encoded_words)
  
  fig <- ggplot(
    data = encoded_words, 
    aes(x = X, y = Y, label = W)
  ) + lims(x=lims$x, y=lims$y) + geom_text(size = 5)
  
  ggsave(name, fig)
}

delete_image <- function(name) {
  "Removes a file with a given name"
  file.remove(name)
}

message <- function(bot, update) {
  chat_id <- update$message$chat_id
  
  msg_text <- update$message$text
  
  wordscodes <- tryCatch({
    encode_text(msg_text)
  })
  
  if (is.null(wordscodes)) {
    bot$sendMessage(chat_id, UNKNOWN_ERROR_TEXT)
    return()
  }
  
  if (length(wordscodes$words) < MIN_WORDS) {
    bot$sendMessage(chat_id, NOT_ENOUGH_WORDS_ERROR_TEXT)
    return()
  }

  encoded_words <- build_dataframe(wordscodes$words, wordscodes$codes)
  
  tmp_image_name <- paste0('tmp', chat_id, '.png')
  
  save_image(tmp_image_name, encoded_words)
  
  bot$sendPhoto(chat_id, tmp_image_name)
  bot$sendMessage(chat_id, SUCCESS_MESSAGE)
  
  delete_image(tmp_image_name)
}

cmd_start <- function(bot, update) {
  chat_id <- update$message$chat_id
  bot$sendMessage(chat_id, START_MESSAGE)
}


updater <- Updater(token = bot_token(botName))

cmd_start_handler <- CommandHandler('start', cmd_start)
msg_handler <- MessageHandler(message)
updater <- updater + cmd_start_handler + msg_handler

updater$start_polling()