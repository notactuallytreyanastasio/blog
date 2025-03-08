document.addEventListener('DOMContentLoaded', () => {
  // DOM elements
  const form = document.getElementById('bookmark-form');
  const titleInput = document.getElementById('title');
  const urlInput = document.getElementById('url');
  const descriptionInput = document.getElementById('description');
  const tagsInput = document.getElementById('tags-input');
  const tagsContainer = document.getElementById('tags-container');
  const tokenInput = document.getElementById('token');
  const saveButton = document.getElementById('save-button');
  const loader = document.getElementById('loader');
  const message = document.getElementById('message');

  // Get current tab information and fill the form
  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    const currentTab = tabs[0];
    titleInput.value = currentTab.title || '';
    urlInput.value = currentTab.url || '';
  });

  // Check for quick bookmark data from context menu
  chrome.storage.local.get(['quickBookmark'], (result) => {
    if (result.quickBookmark) {
      titleInput.value = result.quickBookmark.title || '';
      urlInput.value = result.quickBookmark.url || '';
      // Clear the stored data
      chrome.storage.local.remove(['quickBookmark']);
    }
  });

  // Load saved token from storage
  chrome.storage.local.get(['token'], (result) => {
    if (result.token) {
      tokenInput.value = result.token;
    }
  });

  // Save token when it changes
  tokenInput.addEventListener('change', () => {
    const token = tokenInput.value.trim();
    if (token) {
      chrome.storage.local.set({ token });
      console.log('Token saved to storage');
    }
  });

  // Tags handling
  const tags = [];

  function updateTagsDisplay() {
    tagsContainer.innerHTML = '';
    tags.forEach((tag, index) => {
      const tagElement = document.createElement('div');
      tagElement.className = 'tag';
      tagElement.innerHTML = `
        #${tag}
        <span class="remove" data-index="${index}">×</span>
      `;
      tagsContainer.appendChild(tagElement);
    });

    // Add click event to remove buttons
    document.querySelectorAll('.tag .remove').forEach(button => {
      button.addEventListener('click', (e) => {
        const index = parseInt(e.target.getAttribute('data-index'));
        tags.splice(index, 1);
        updateTagsDisplay();
      });
    });
  }

  tagsInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault();
      const value = tagsInput.value.trim();
      if (value && !tags.includes(value)) {
        tags.push(value);
        tagsInput.value = '';
        updateTagsDisplay();
      }
    }
  });

  tagsInput.addEventListener('blur', () => {
    const value = tagsInput.value.trim();
    if (value) {
      const newTags = value.split(',').map(tag => tag.trim()).filter(tag => tag && !tags.includes(tag));
      tags.push(...newTags);
      tagsInput.value = '';
      updateTagsDisplay();
    }
  });

  // Form submission
  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const token = tokenInput.value.trim();
    if (!token) {
      showMessage('Please enter your authentication token', 'error');
      return;
    }

    // Disable form and show loader
    saveButton.disabled = true;
    loader.style.display = 'block';
    message.textContent = '';

    try {
      console.log('Connecting to Phoenix socket...');

      // Connect to Phoenix socket with our simplified client
      const socket = new PhoenixSocket("ws://localhost:4000/socket", {
        params: { token }
      });

      socket.connect();

      // Create a timeout to handle connection failures
      const connectionTimeout = setTimeout(() => {
        showMessage('Connection timeout. Server not responding.', 'error');
        resetForm();
      }, 5000);

      // Wait for connection to establish
      setTimeout(() => {
        if (socket.connected) {
          clearTimeout(connectionTimeout);

          // Join the client channel
          const channelTopic = `bookmark:client:${token}`;
          console.log(`Joining channel: ${channelTopic}`);
          const channel = socket.channel(channelTopic);

          try {
            // Join the channel
            channel.join()
              .then(() => {
                console.log('Channel joined successfully');
                sendBookmark(socket, channel);
              })
              .catch(error => {
                console.error('Error joining channel:', error);
                showMessage(`Error joining channel: ${error.message}`, 'error');
                resetForm();
              });

            // Add error handler
            channel.onError((resp) => {
              console.error('Channel error:', resp);
              showMessage(`Channel error: ${resp.reason || 'Unknown error'}`, 'error');
              resetForm();
            });
          } catch (error) {
            console.error('Error setting up channel:', error);
            showMessage(`Error: ${error.message}`, 'error');
            resetForm();
          }
        } else {
          clearTimeout(connectionTimeout);
          console.error('WebSocket not connected');
          showMessage('Could not establish WebSocket connection', 'error');
          resetForm();
        }
      }, 1000);
    } catch (error) {
      console.error('Connection error:', error);
      showMessage(`Connection error: ${error.message}`, 'error');
      resetForm();
    }
  });

  function sendBookmark(socket, channel) {
    console.log('Preparing to send bookmark data');

    const payload = {
      title: titleInput.value,
      url: urlInput.value,
      description: descriptionInput.value,
      tags: tags
    };

    console.log('Bookmark payload:', payload);

    try {
      const pushResult = channel.push('bookmark:create', payload);

      pushResult.receive('ok', (resp) => {
        console.log('Bookmark created successfully:', resp);
        showMessage('Bookmark saved successfully!', 'success');

        // Close the popup after success
        setTimeout(() => {
          socket.disconnect();
          window.close();
        }, 1500);
      });

      pushResult.receive('error', (resp) => {
        console.error('Failed to create bookmark:', resp);
        showMessage(`Error: ${formatErrors(resp)}`, 'error');
        socket.disconnect();
        resetForm();
      });

      // Set a timeout in case we don't get a response
      setTimeout(() => {
        if (saveButton.disabled) {
          console.warn('No response received from server');
          showMessage('No response from server. Your bookmark may or may not have been saved.', 'error');
          socket.disconnect();
          resetForm();
        }
      }, 10000);
    } catch (error) {
      console.error('Error sending bookmark:', error);
      showMessage(`Error: ${error.message}`, 'error');
      socket.disconnect();
      resetForm();
    }
  }

  function formatErrors(errors) {
    if (!errors) return 'Unknown error';

    if (typeof errors === 'string') return errors;

    return Object.entries(errors)
      .map(([field, messages]) => `${field}: ${Array.isArray(messages) ? messages.join(', ') : messages}`)
      .join('; ');
  }

  function showMessage(text, type) {
    message.textContent = text;
    message.className = type;
    console.log(`Message (${type}): ${text}`);
  }

  function resetForm() {
    saveButton.disabled = false;
    loader.style.display = 'none';
  }
});