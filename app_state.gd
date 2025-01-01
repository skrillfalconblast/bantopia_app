extends Node

# For networking
const IS_PRODUCTION = true

# This is likely terrible practise because we use the production api for debugging.
const DOMAIN = "bantopia.com" if IS_PRODUCTION else "localhost:8000"

var API_URL = "https://%s/api" % [DOMAIN] if IS_PRODUCTION else "http://%s/api" % [DOMAIN]
const WEBSOCKET_PROTOCOL = "wss://" if IS_PRODUCTION else "ws://"
const WEBSOCKET_URL = WEBSOCKET_PROTOCOL + DOMAIN + '/ws/{post_code}/chat'
