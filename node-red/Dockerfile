# DOCKERFILE FOR NODE-RED

# to build:
#    docker build -t nodered_mqtt-telegram .

FROM nodered/node-red

# Copy package.json to the WORKDIR so npm builds all
# of your added nodes modules for Node-RED
COPY package.json .
RUN npm install --unsafe-perm --no-update-notifier --no-fund --only=production
