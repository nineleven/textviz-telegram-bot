library(telegram.bot)


source('config.R')


if (file_test('-f', ENV_PATH)) {
  readRenviron(ENV_PATH)
}


updater <- Updater(token = bot_token(botName))


message <- function(bot, update) {
  chat_id <- update$message$chat_id
  
  msg_text <- update$message$text
  bot$sendMessage(chat_id, paste('Bip, bop, encoding', msg_text, ':)'))
  
}


msg_handler <- MessageHandler(message)
updater <- updater + msg_handler

updater$start_polling()