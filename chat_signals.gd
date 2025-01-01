extends Node

signal message_sent(message_content: String)
signal message_received(message_content: String)
signal load_messages(messages: Array)
signal loaded_messages(number_of_messages: int)
signal chat_scroll_clicked
