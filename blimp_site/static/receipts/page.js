// /very_direct_message in the browser: what ReceiptMessageLive did over its
// socket that needs no server, and the queue, which asks the server for
// its panel. The form itself is a plain multipart POST (src/99_receipts.blimp).
(function () {
  var form = document.querySelector('form.message-form');
  if (!form) return;
  var input = form.querySelector('textarea[name="message"]');
  var send = form.querySelector('.send-button');
  var file = form.querySelector('input[type="file"][name="image"]');
  var queueButton = form.querySelector('.queue-button');
  var buttons = form.querySelector('.button-container');
  var counter = document.querySelector('.os-statusbar span:last-child');

  // String.length/1 counts graphemes: "🎉" is 1, "é" as e + accent is 1.
  var segmenter = window.Intl && Intl.Segmenter ? new Intl.Segmenter() : null;
  function graphemes(s) {
    if (!segmenter) return Array.from(s).length;
    var n = 0;
    for (var _ of segmenter.segment(s)) n++;
    return n;
  }

  // disabled={@message == ""}: only the empty string; spaces enable Send.
  function onInput() {
    send.disabled = input.value === '';
    if (counter) counter.textContent = 'Characters: ' + graphemes(input.value);
  }
  input.addEventListener('input', onInput);
  onInput();

  // The upload entry: its name and a Cancel button, after the buttons.
  var entry = null;
  function showEntry() {
    if (entry) { entry.remove(); entry = null; }
    var f = file.files && file.files[0];
    if (!f) return;
    entry = document.createElement('div');
    entry.appendChild(document.createTextNode(f.name + ' '));
    var cancel = document.createElement('button');
    cancel.type = 'button';
    cancel.textContent = 'Cancel';
    cancel.addEventListener('click', function () { file.value = ''; showEntry(); });
    entry.appendChild(cancel);
    buttons.after(entry);
  }
  file.addEventListener('change', showEntry);
  showEntry();

  // View Queue / Hide Queue: the ten newest messages, fetched when shown.
  var panel = null;
  var label = null;
  for (var i = queueButton.childNodes.length - 1; i >= 0; i--) {
    var n = queueButton.childNodes[i];
    if (n.nodeType === 3 && n.textContent.trim() !== '') { label = n; break; }
  }
  function setLabel(text) { if (label) label.textContent = '\n        ' + text + '\n      '; }
  queueButton.addEventListener('click', function () {
    if (panel) { panel.remove(); panel = null; setLabel('View Queue'); return; }
    fetch('/very_direct_message/queue', { credentials: 'same-origin' })
      .then(function (r) {
        if (!r.ok) throw new Error('the queue answered ' + r.status);
        return r.text();
      })
      .then(function (html) {
        if (panel) return;
        var holder = document.createElement('div');
        holder.innerHTML = html;
        panel = holder.firstElementChild;
        form.appendChild(panel);
        setLabel('Hide Queue');
      })
      .catch(function (e) { console.error('very_direct_message: ' + e.message); });
  });

  // Hooks.Draggable (assets/js/app.js), for this one window.
  var win = document.getElementById('dm-window');
  var bar = win && win.querySelector('.os-titlebar');
  if (!bar) return;
  if (getComputedStyle(win).position === 'static') win.style.position = 'relative';
  bar.style.cursor = 'grab';
  var dragging = false, sx = 0, sy = 0, ix = 0, iy = 0, placeholder = null;
  function down(e) {
    if (e.target.closest('button, a, .close-box, .os-btn-close')) return;
    dragging = true;
    bar.style.cursor = 'grabbing';
    sx = e.clientX; sy = e.clientY;
    var rect = win.getBoundingClientRect();
    ix = rect.left; iy = rect.top;
    if (!placeholder && win.parentNode) {
      placeholder = document.createElement('div');
      placeholder.style.width = rect.width + 'px';
      placeholder.style.height = rect.height + 'px';
      placeholder.style.minWidth = rect.width + 'px';
      placeholder.style.flexShrink = '0';
      placeholder.style.visibility = 'hidden';
      placeholder.style.marginLeft = win.style.marginLeft === 'auto' ? 'auto' : getComputedStyle(win).marginLeft;
      placeholder.style.alignSelf = getComputedStyle(win).alignSelf;
      win.parentNode.insertBefore(placeholder, win);
    }
    win.style.position = 'fixed';
    win.style.transform = 'none';
    win.style.left = ix + 'px';
    win.style.top = iy + 'px';
    win.style.right = 'auto';
    win.style.bottom = 'auto';
    win.style.zIndex = '1000';
    win.style.width = rect.width + 'px';
    if (e.preventDefault) e.preventDefault();
  }
  function move(e) {
    if (!dragging) return;
    win.style.left = (ix + e.clientX - sx) + 'px';
    win.style.top = (iy + e.clientY - sy) + 'px';
  }
  function up() {
    if (!dragging) return;
    dragging = false;
    bar.style.cursor = 'grab';
  }
  bar.addEventListener('mousedown', down);
  document.addEventListener('mousemove', move);
  document.addEventListener('mouseup', up);
  bar.addEventListener('touchstart', function (e) {
    if (e.target.closest('button, a, .close-box, .os-btn-close')) return;
    var t = e.touches[0];
    down({ clientX: t.clientX, clientY: t.clientY, target: e.target });
  }, { passive: true });
  document.addEventListener('touchmove', function (e) {
    if (!dragging) return;
    var t = e.touches[0];
    move({ clientX: t.clientX, clientY: t.clientY });
  }, { passive: true });
  document.addEventListener('touchend', up);
})();
