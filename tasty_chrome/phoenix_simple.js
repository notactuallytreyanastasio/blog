/**
 * Simplified Phoenix WebSocket Client
 * A lightweight alternative to the full Phoenix.js client
 */

class PhoenixSocket {
  constructor(endpoint, opts = {}) {
    this.endpoint = endpoint;
    this.params = opts.params || {};
    this.timeout = opts.timeout || 10000;
    this.heartbeatIntervalMs = opts.heartbeatIntervalMs || 30000;
    this.socket = null;
    this.channels = {};
    this.messageCallbacks = [];
    this.connected = false;
    this.heartbeatTimer = null;
    this.pendingHeartbeatRef = null;
    this.ref = 0;

    // Bind methods to maintain context
    this.handleOpen = this.handleOpen.bind(this);
    this.handleMessage = this.handleMessage.bind(this);
    this.handleError = this.handleError.bind(this);
    this.handleClose = this.handleClose.bind(this);
  }

  connect() {
    if (this.socket) {
      return;
    }

    const url = this.buildUrl();
    this.socket = new WebSocket(url);

    this.socket.onopen = this.handleOpen;
    this.socket.onmessage = this.handleMessage;
    this.socket.onerror = this.handleError;
    this.socket.onclose = this.handleClose;
  }

  disconnect() {
    if (this.socket) {
      this.stopHeartbeat();
      this.socket.close();
      this.socket = null;
      this.connected = false;
    }
  }

  handleOpen() {
    console.log(`Connected to ${this.endpoint}`);
    this.connected = true;
    this.startHeartbeat();
  }

  handleMessage(event) {
    try {
      const message = JSON.parse(event.data);
      console.log('Received message:', message);

      // Handle heartbeat responses
      if (message.ref === this.pendingHeartbeatRef) {
        this.pendingHeartbeatRef = null;
        clearTimeout(this.heartbeatTimer);
        this.startHeartbeat();
        return;
      }

      // Handle channel messages
      const { topic, event: eventName, payload, ref } = message;

      // Check if this is a response to a channel join
      if (eventName === 'phx_reply' && this.channels[topic]) {
        if (payload.status === 'ok') {
          this.channels[topic].joined = true;
          if (this.channels[topic].onJoin) {
            this.channels[topic].onJoin(payload);
          }
        } else if (payload.status === 'error') {
          if (this.channels[topic].onError) {
            this.channels[topic].onError(payload);
          }
        }
      }

      // Forward to channel callbacks
      if (this.channels[topic] && this.channels[topic].callbacks[eventName]) {
        this.channels[topic].callbacks[eventName].forEach(callback => {
          callback(payload, ref);
        });
      }

      // Forward to general message callbacks
      this.messageCallbacks.forEach(callback => {
        callback(message);
      });
    } catch (error) {
      console.error('Error parsing message:', error);
    }
  }

  handleError(error) {
    console.error('WebSocket error:', error);
    this.stopHeartbeat();
  }

  handleClose(event) {
    console.log(`WebSocket closed: ${event.code} ${event.reason}`);
    this.connected = false;
    this.stopHeartbeat();

    // Clean up channels
    Object.keys(this.channels).forEach(topic => {
      this.channels[topic].joined = false;
    });
  }

  channel(topic, params = {}) {
    if (!this.channels[topic]) {
      this.channels[topic] = {
        topic,
        params,
        joined: false,
        callbacks: {},
        onJoin: null,
        onError: null
      };
    }

    return {
      join: () => this.joinChannel(topic),
      leave: () => this.leaveChannel(topic),
      on: (event, callback) => this.on(topic, event, callback),
      push: (event, payload) => this.push(topic, event, payload),
      onJoin: (callback) => { this.channels[topic].onJoin = callback; },
      onError: (callback) => { this.channels[topic].onError = callback; }
    };
  }

  joinChannel(topic) {
    if (!this.channels[topic]) {
      throw new Error(`No channel found for topic: ${topic}`);
    }

    const ref = this.makeRef();
    const message = {
      topic,
      event: 'phx_join',
      payload: this.channels[topic].params,
      ref
    };

    this.send(message);

    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        reject(new Error('Join timeout'));
      }, this.timeout);

      this.channels[topic].onJoin = (payload) => {
        clearTimeout(timeoutId);
        resolve(payload);
      };

      this.channels[topic].onError = (payload) => {
        clearTimeout(timeoutId);
        reject(new Error(payload.response?.reason || 'Join failed'));
      };
    });
  }

  leaveChannel(topic) {
    if (!this.channels[topic]) {
      return;
    }

    const ref = this.makeRef();
    const message = {
      topic,
      event: 'phx_leave',
      payload: {},
      ref
    };

    this.send(message);
    delete this.channels[topic];
  }

  on(topic, event, callback) {
    if (!this.channels[topic]) {
      throw new Error(`No channel found for topic: ${topic}`);
    }

    if (!this.channels[topic].callbacks[event]) {
      this.channels[topic].callbacks[event] = [];
    }

    this.channels[topic].callbacks[event].push(callback);

    return () => {
      this.channels[topic].callbacks[event] = this.channels[topic].callbacks[event].filter(
        cb => cb !== callback
      );
    };
  }

  push(topic, event, payload = {}) {
    if (!this.channels[topic]) {
      throw new Error(`No channel found for topic: ${topic}`);
    }

    const ref = this.makeRef();
    const message = {
      topic,
      event,
      payload,
      ref
    };

    this.send(message);

    return {
      receive: (status, callback) => {
        const replyEvent = `phx_reply`;

        const removeListener = this.on(topic, replyEvent, (payload, msgRef) => {
          if (msgRef === ref && payload.status === status) {
            removeListener();
            callback(payload.response);
          }
        });
      }
    };
  }

  onMessage(callback) {
    this.messageCallbacks.push(callback);
    return () => {
      this.messageCallbacks = this.messageCallbacks.filter(cb => cb !== callback);
    };
  }

  startHeartbeat() {
    this.stopHeartbeat();
    this.heartbeatTimer = setTimeout(() => {
      if (this.connected) {
        this.pendingHeartbeatRef = this.makeRef();
        this.push('phoenix', 'heartbeat', {});
      }
    }, this.heartbeatIntervalMs);
  }

  stopHeartbeat() {
    clearTimeout(this.heartbeatTimer);
    this.heartbeatTimer = null;
    this.pendingHeartbeatRef = null;
  }

  makeRef() {
    this.ref += 1;
    return this.ref.toString();
  }

  send(message) {
    if (!this.connected) {
      console.warn('Tried to send message while disconnected', message);
      return false;
    }

    try {
      this.socket.send(JSON.stringify(message));
      return true;
    } catch (error) {
      console.error('Error sending message:', error);
      return false;
    }
  }

  buildUrl() {
    // Append websocket suffix and params
    let url = this.endpoint;
    if (!url.endsWith('/websocket')) {
      url = `${url}/websocket`;
    }

    // Add params as query string
    if (Object.keys(this.params).length > 0) {
      const params = new URLSearchParams();
      Object.entries(this.params).forEach(([key, value]) => {
        params.append(key, value);
      });
      url = `${url}?${params.toString()}`;
    }

    return url;
  }
}

// Export globally
window.PhoenixSocket = PhoenixSocket;