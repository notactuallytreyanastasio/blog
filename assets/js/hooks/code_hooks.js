// Code highlighting and toolbar hooks
export default {
  Highlight: {
    mounted() {
      // Initialize syntax highlighting and code block enhancers
      this.highlightCode();
      this.setupCodeToolbar();
    },

    highlightCode() {
      // Get all pre > code elements
      const codeBlocks = this.el.querySelectorAll("pre > code");

      if (codeBlocks.length === 0) return;

      // Import Prism.js dynamically to enhance code blocks
      import("prismjs").then((Prism) => {
        // Import additional components
        import("prismjs/plugins/line-numbers/prism-line-numbers.js");
        import("prismjs/components/prism-elixir.js");
        import("prismjs/components/prism-javascript.js");
        import("prismjs/components/prism-css.js");
        import("prismjs/components/prism-markup.js");
        import("prismjs/components/prism-bash.js");
        import("prismjs/components/prism-json.js");
        import("prismjs/components/prism-sql.js");
        import("prismjs/components/prism-yaml.js");
        import("prismjs/components/prism-markdown.js");

        // Highlight each code block
        codeBlocks.forEach((codeBlock) => {
          Prism.highlightElement(codeBlock);
        });
      });
    },

    setupCodeToolbar() {
      // Add a toolbar to each code block
      const codeBlocks = this.el.querySelectorAll("pre > code");

      codeBlocks.forEach((codeBlock) => {
        const pre = codeBlock.parentElement;

        // Create toolbar
        const toolbar = document.createElement("div");
        toolbar.className = "code-toolbar absolute top-0 right-0 p-1 bg-gray-100 rounded-bl-md opacity-80 flex items-center space-x-2 text-xs text-gray-600";

        // Add copy button
        const copyBtn = document.createElement("button");
        copyBtn.className = "px-1.5 py-0.5 hover:bg-gray-200 rounded flex items-center";
        copyBtn.innerHTML = `
          <svg class="w-3.5 h-3.5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"></path>
          </svg>
          Copy
        `;

        copyBtn.addEventListener("click", () => {
          // Copy code to clipboard
          const textToCopy = codeBlock.textContent;
          navigator.clipboard.writeText(textToCopy).then(() => {
            // Change button text temporarily
            copyBtn.innerHTML = `
              <svg class="w-3.5 h-3.5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
              </svg>
              Copied!
            `;
            setTimeout(() => {
              copyBtn.innerHTML = `
                <svg class="w-3.5 h-3.5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"></path>
                </svg>
                Copy
              `;
            }, 2000);
          });
        });

        // Add language label if available
        const languageClass = Array.from(codeBlock.classList).find(cls => cls.startsWith('language-'));
        if (languageClass) {
          const language = languageClass.replace('language-', '');
          const langLabel = document.createElement("span");
          langLabel.className = "px-1.5 py-0.5 bg-gray-200 rounded";
          langLabel.textContent = language;
          toolbar.appendChild(langLabel);
        }

        toolbar.appendChild(copyBtn);
        pre.appendChild(toolbar);

        // Make pre element position relative for absolute positioning of toolbar
        pre.style.position = "relative";
      });
    },

    getTextNodes(node) {
      let textNodes = [];
      const walker = document.createTreeWalker(
        node,
        NodeFilter.SHOW_TEXT,
        null,
        false
      );

      let n;
      while (n = walker.nextNode()) {
        if (n.textContent.trim() !== '') {
          textNodes.push(n);
        }
      }

      return textNodes;
    }
  }
}