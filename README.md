# TextViz telegram interface

This is my student project for a python programming course at SPbSTU.

The idea is the following:
A client takes an arbitrary text from user and sends it to a server. A django server extracts the words from the text and encodes each word as a 1x26 vector. Then those codes are passed back to the client, where its' dimensionality is reduced to 1x2. Finally, the codes are plotted on a graph with the words, corresponding to those codes as label. The server part of this project can be found [here](https://github.com/nineleven/textviz-server). And [this](https://github.com/nineleven/text-data-visualization/edit/develop/README.md) is the link for the RShiny client.

Current repository contains a telegram interface for the described application.

## Installation
Install R from https://www.r-project.org/

Install required R packages with
```
R -e install.packages(c('telegram.bot', 'ggplot2', 'httr'))
```
Next, create a bot and put it's name into [src/config.R](src/config.R). Also, put the telegram api token you got from @FatherBot into .env file in [src](src) as follows:
```
R_TELEGRAM_BOT_YOUR_BOTS_NAME=your_token
```
where YOUR_BOTS_NAME is the name of the bot you created and your_token is the api token.

Then, run
```
R -e shiny::runApp('src/bot.R')
```
The bot should start to respond to messages.
