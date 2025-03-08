// Background service worker for Tasty Bookmarks extension

// Listen for installation event
chrome.runtime.onInstalled.addListener(() => {
  console.log('Tasty Bookmarks extension installed');
});

// Context menu for quick bookmarking
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'tastyBookmark',
    title: 'Save to Tasty Bookmarks',
    contexts: ['page', 'link']
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'tastyBookmark') {
    // Get the URL from the context
    const url = info.linkUrl || tab.url;
    const title = tab.title || url;

    // Open the popup with pre-filled information
    chrome.storage.local.set({
      quickBookmark: {
        url,
        title
      }
    }, () => {
      chrome.action.openPopup();
    });
  }
});

// Handle any icon badge updates or notifications here