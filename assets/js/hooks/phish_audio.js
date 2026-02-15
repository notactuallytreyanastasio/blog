function fmtSec(s) {
  if (!s || !isFinite(s)) return "0:00";
  const m = Math.floor(s / 60);
  const sec = Math.floor(s % 60);
  return `${m}:${String(sec).padStart(2, "0")}`;
}

const PhishAudio = {
  mounted() {
    this.audio = document.createElement("audio");
    this.nowPlaying = null;

    // Create player bar (hidden initially)
    this.playerBar = document.createElement("div");
    this.playerBar.className = "phish-player";
    this.playerBar.style.display = "none";
    this.playerBar.innerHTML = `
      <div class="phish-player-progress-bg">
        <div class="phish-player-progress-fill"></div>
      </div>
      <div class="phish-player-inner">
        <button class="phish-player-stop">■</button>
        <span class="phish-player-icon">▶</span>
        <div class="phish-player-info">
          <span class="phish-player-song"></span>
          <span class="phish-player-time">0:00 / 0:00</span>
        </div>
        <span class="phish-player-via">via PhishJustJams</span>
      </div>
    `;
    document.body.appendChild(this.playerBar);

    // Elements
    this.progressBg = this.playerBar.querySelector(
      ".phish-player-progress-bg"
    );
    this.progressFill = this.playerBar.querySelector(
      ".phish-player-progress-fill"
    );
    this.songEl = this.playerBar.querySelector(".phish-player-song");
    this.timeEl = this.playerBar.querySelector(".phish-player-time");
    this.stopBtn = this.playerBar.querySelector(".phish-player-stop");

    // Events
    this.audio.addEventListener("timeupdate", () => this.updateProgress());
    this.audio.addEventListener("loadedmetadata", () => this.updateProgress());
    this.audio.addEventListener("ended", () => this.stop());

    this.stopBtn.addEventListener("click", () => this.stop());
    this.progressBg.addEventListener("click", (e) => {
      if (!this.audio.duration) return;
      const rect = this.progressBg.getBoundingClientRect();
      const ratio = (e.clientX - rect.left) / rect.width;
      this.audio.currentTime = ratio * this.audio.duration;
    });

    // Listen for play events from LiveView (mobile)
    this.handleEvent("play-jam", (data) => this.play(data));

    // Listen for play events from chart hook (desktop)
    this._chartPlayHandler = (e) => this.play(e.detail);
    window.addEventListener("phish:play-jam", this._chartPlayHandler);
  },

  destroyed() {
    this.stop();
    if (this.playerBar) this.playerBar.remove();
    if (this.audio) {
      this.audio.pause();
      this.audio.src = "";
    }
    window.removeEventListener("phish:play-jam", this._chartPlayHandler);
  },

  play({ url, date, song }) {
    if (this.nowPlaying && this.nowPlaying.url === url) {
      if (this.audio.paused) {
        this.audio.play();
      } else {
        this.audio.pause();
      }
      return;
    }

    this.nowPlaying = { url, date, song };
    this.audio.src = url;
    this.audio.play();

    this.songEl.innerHTML = `<strong>${song}</strong> <span style="color:#999;font-weight:400;margin-left:4px;">${date}</span>`;
    this.playerBar.style.display = "block";
  },

  stop() {
    this.audio.pause();
    this.audio.src = "";
    this.nowPlaying = null;
    this.playerBar.style.display = "none";
  },

  updateProgress() {
    const cur = this.audio.currentTime || 0;
    const dur = this.audio.duration || 0;
    const pct = dur > 0 ? (cur / dur) * 100 : 0;
    this.progressFill.style.width = `${pct}%`;
    this.timeEl.textContent = `${fmtSec(cur)} / ${fmtSec(dur)}`;
  },
};

export default PhishAudio;
