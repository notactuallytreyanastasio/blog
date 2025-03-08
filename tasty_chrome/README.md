# Tasty Bookmarks Chrome Extension

Chrome extension for the Tasty Bookmarks application.

## Features

- Save the current page as a bookmark with one click
- Add a description and tags to your bookmarks
- Quickly access your bookmarks from any device

## Development Setup

1. Clone this repository
2. Navigate to `chrome://extensions/` in Chrome
3. Enable "Developer mode" in the top right
4. Click "Load unpacked" and select the `tasty_chrome` folder
5. The extension is now installed

## Building for Production

When ready for production:

1. Generate icons (if using the provided SVG):
   ```
   python generate_icons.py
   ```

2. Package the extension:
   - Zip all files excluding `generate_icons.py` and `README.md`
   - Upload to the Chrome Web Store

## Authentication

This extension requires an authentication token from the Tasty Bookmarks application:

1. Log into your Tasty Bookmarks account at `http://localhost:4000`
2. Go to your profile page
3. Click "Generate WebSocket Token"
4. Copy the token and paste it into the extension

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT