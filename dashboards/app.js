const apiBase = "http://localhost:8000";
const defaultScopes = [
  "user-read-recently-played",
  "user-top-read",
  "user-library-read",
  "user-read-private",
  "user-read-email"
].join(" ");

const fallbackData = {
  overview: {
    music_plays: 184,
    saved_tracks: 92,
    saved_albums: 18,
    unique_tracks_played: 137,
    unique_artists_played: 64,
    avg_track_popularity: 67.4
  },
  monthly: [
    { label: "Jan", plays: 22 },
    { label: "Fev", plays: 34 },
    { label: "Mar", plays: 28 },
    { label: "Abr", plays: 49 },
    { label: "Mai", plays: 41 },
    { label: "Jun", plays: 57 }
  ],
  playsByDay: [
    { label: "03/07", plays: 16 },
    { label: "04/07", plays: 22 },
    { label: "05/07", plays: 12 },
    { label: "06/07", plays: 31 },
    { label: "07/07", plays: 27 },
    { label: "08/07", plays: 36 },
    { label: "09/07", plays: 21 }
  ],
  playsByHour: [
    0, 0, 1, 0, 0, 2, 4, 6, 5, 3, 2, 4,
    8, 11, 10, 9, 7, 13, 15, 18, 20, 16, 9, 4
  ],
  topArtists: [
    { name: "Olivia Rodrigo", value: 31, meta: "pop rock" },
    { name: "Taylor Swift", value: 28, meta: "pop" },
    { name: "Billie Eilish", value: 24, meta: "alt pop" },
    { name: "Lana Del Rey", value: 19, meta: "art pop" },
    { name: "Ariana Grande", value: 17, meta: "r&b pop" }
  ],
  topAlbums: [
    { name: "GUTS", value: 22, meta: "Olivia Rodrigo" },
    { name: "HIT ME HARD AND SOFT", value: 18, meta: "Billie Eilish" },
    { name: "1989", value: 16, meta: "Taylor Swift" },
    { name: "SOS", value: 14, meta: "SZA" },
    { name: "Midnights", value: 12, meta: "Taylor Swift" }
  ],
  savedTracks: [
    { track: "vampire", artist: "Olivia Rodrigo", album: "GUTS", popularity: 86, added_at: "2026-07-05" },
    { track: "BIRDS OF A FEATHER", artist: "Billie Eilish", album: "HIT ME HARD AND SOFT", popularity: 94, added_at: "2026-07-04" },
    { track: "Kill Bill", artist: "SZA", album: "SOS", popularity: 88, added_at: "2026-07-03" },
    { track: "Style", artist: "Taylor Swift", album: "1989", popularity: 82, added_at: "2026-07-01" }
  ],
  libraryArtists: [
    { name: "Taylor Swift", value: 11, meta: "musicas curtidas" },
    { name: "SZA", value: 8, meta: "musicas curtidas" },
    { name: "Olivia Rodrigo", value: 7, meta: "musicas curtidas" },
    { name: "Billie Eilish", value: 6, meta: "musicas curtidas" }
  ],
  rankings: {
    short_term: {
      tracks: [
        { name: "vampire", value: 1, meta: "Olivia Rodrigo" },
        { name: "BIRDS OF A FEATHER", value: 2, meta: "Billie Eilish" },
        { name: "Saturn", value: 3, meta: "SZA" }
      ],
      artists: [
        { name: "Olivia Rodrigo", value: 1, meta: "popularity 83" },
        { name: "Billie Eilish", value: 2, meta: "popularity 91" },
        { name: "SZA", value: 3, meta: "popularity 89" }
      ]
    },
    medium_term: {
      tracks: [
        { name: "Style", value: 1, meta: "Taylor Swift" },
        { name: "Kill Bill", value: 2, meta: "SZA" },
        { name: "bad idea right?", value: 3, meta: "Olivia Rodrigo" }
      ],
      artists: [
        { name: "Taylor Swift", value: 1, meta: "popularity 100" },
        { name: "SZA", value: 2, meta: "popularity 89" },
        { name: "Olivia Rodrigo", value: 3, meta: "popularity 83" }
      ]
    },
    long_term: {
      tracks: [
        { name: "Summertime Sadness", value: 1, meta: "Lana Del Rey" },
        { name: "The Less I Know The Better", value: 2, meta: "Tame Impala" },
        { name: "good 4 u", value: 3, meta: "Olivia Rodrigo" }
      ],
      artists: [
        { name: "Lana Del Rey", value: 1, meta: "popularity 87" },
        { name: "Taylor Swift", value: 2, meta: "popularity 100" },
        { name: "Olivia Rodrigo", value: 3, meta: "popularity 83" }
      ]
    }
  }
};

let activeRange = "short_term";
let rankingsData = fallbackData.rankings;

async function fetchJson(path, fallback) {
  try {
    const response = await fetch(`${apiBase}${path}`);
    if (!response.ok) throw new Error("API unavailable");
    document.getElementById("data-status").textContent = "api conectada";
    return response.json();
  } catch {
    document.getElementById("data-status").textContent = "dados locais";
    return fallback;
  }
}

async function postJson(path, payload) {
  const response = await fetch(`${apiBase}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(payload)
  });

  if (!response.ok) throw new Error("API unavailable");
  return response.json();
}

function formatNumber(value) {
  if (value === null || value === undefined) return "-";
  return Number(value).toLocaleString("pt-BR");
}

function renderMetricCards(data) {
  const cards = [
    ["Plays", data.music_plays, "historico coletado"],
    ["Curtidas", data.saved_tracks, "musicas salvas"],
    ["Albuns", data.saved_albums, "albuns salvos"],
    ["Artistas", data.unique_artists_played, "unicos no historico"],
    ["Musicas unicas", data.unique_tracks_played, "tocadas ao menos uma vez"],
    ["Pop. musicas", data.avg_track_popularity, "media das faixas"],
    ["Fonte", "SQL", "views do PostgreSQL"]
  ];

  document.getElementById("overview-cards").innerHTML = cards.map(([label, value, sub]) => `
    <article class="metric-card">
      <div class="metric-label">${label}</div>
      <div class="metric-value">${formatNumber(value)}</div>
      <div class="metric-sub">${sub}</div>
    </article>
  `).join("");
}

function renderBarChart(elementId, rows, valueKey) {
  const max = Math.max(...rows.map((row) => Number(row[valueKey]) || 0), 1);
  const html = `
    <div class="bar-chart" style="--count:${rows.length}">
      ${rows.map((row) => {
        const value = Number(row[valueKey]) || 0;
        const height = Math.max((value / max) * 100, 4);
        return `
          <div class="bar-wrap" title="${row.label}: ${value}">
            <div class="bar" style="height:${height}%"></div>
            <div class="bar-label">${row.label}</div>
          </div>
        `;
      }).join("")}
    </div>
  `;
  document.getElementById(elementId).innerHTML = html;
}

function renderRankList(elementId, rows, suffix = "plays") {
  document.getElementById(elementId).innerHTML = rows.map((row, index) => `
    <div class="rank-item">
      <div class="rank-number">${index + 1}</div>
      <div>
        <div class="rank-title">${row.name}</div>
        <div class="rank-meta">${row.meta || ""}</div>
      </div>
      <div class="rank-value">${row.value} ${suffix}</div>
    </div>
  `).join("");
}

function renderHourGrid(rows) {
  const max = Math.max(...rows, 1);
  document.getElementById("plays-hour-chart").innerHTML = rows.map((value, hour) => `
    <div class="hour-cell" style="--intensity:${Math.round((value / max) * 78)}" title="${hour}h: ${value}">
      ${String(hour).padStart(2, "0")}h
    </div>
  `).join("");
}

function renderDonut(data) {
  const track = Math.min(Number(data.avg_track_popularity) || 0, 100);
  const trackDeg = `${track * 3.6}deg`;
  document.getElementById("popularity-donut").innerHTML = `
    <div class="donut" style="--track:${trackDeg}; --artist:${trackDeg}">
      <div class="donut-inner">
        <div>
          <div class="donut-value">${Math.round(track)}</div>
          <div class="donut-label">musicas</div>
        </div>
      </div>
    </div>
  `;
}

function renderSavedTracks(rows) {
  document.getElementById("saved-tracks-table").innerHTML = `
    <table>
      <thead>
        <tr>
          <th>Musica</th>
          <th>Artista</th>
          <th>Album</th>
          <th>Popularidade</th>
          <th>Salva em</th>
        </tr>
      </thead>
      <tbody>
        ${rows.map((row) => `
          <tr>
            <td>${row.track}</td>
            <td>${row.artist}</td>
            <td>${row.album}</td>
            <td>${row.popularity ?? "-"}</td>
            <td>${row.added_at ?? "-"}</td>
          </tr>
        `).join("")}
      </tbody>
    </table>
  `;
}

function renderRankings() {
  const data = rankingsData[activeRange] || fallbackData.rankings[activeRange];
  renderRankList("top-tracks-ranking", data.tracks, "");
  renderRankList("top-artists-ranking", data.artists, "");
}

function getStoredAuthConfig() {
  const rawConfig = localStorage.getItem("spotify_auth_config");
  if (!rawConfig) return null;

  try {
    return JSON.parse(rawConfig);
  } catch {
    return null;
  }
}

function setAuthUiState({ connected, apiStatus, credentials, nextStep }) {
  const authState = document.getElementById("auth-state");
  authState.textContent = connected ? "conectado" : "desconectado";
  authState.classList.toggle("connected", connected);
  authState.classList.toggle("disconnected", !connected);
  document.getElementById("auth-api-status").textContent = apiStatus;
  document.getElementById("credential-status").textContent = credentials;
  document.getElementById("next-auth-step").textContent = nextStep;
}

function loadAuthForm() {
  const config = getStoredAuthConfig();
  document.getElementById("spotify-client-id").value = config?.client_id || "";
  document.getElementById("spotify-redirect-uri").value = config?.redirect_uri || "http://localhost:8000/auth/callback";
  document.getElementById("spotify-scopes").value = config?.scopes || defaultScopes;

  if (config?.client_id) {
    setAuthUiState({
      connected: false,
      apiStatus: "aguardando login",
      credentials: "salvas localmente",
      nextStep: "conectar com Spotify"
    });
  } else {
    setAuthUiState({
      connected: false,
      apiStatus: "aguardando",
      credentials: "nao salvas",
      nextStep: "configurar app Spotify"
    });
  }
}

async function checkAuthStatus() {
  try {
    const status = await fetchJson("/auth/status", null);
    if (!status) return;

    setAuthUiState({
      connected: Boolean(status.connected),
      apiStatus: "online",
      credentials: status.has_credentials ? "salvas na API" : "pendentes",
      nextStep: status.connected ? "coletar dados" : "conectar com Spotify"
    });
  } catch {
    const config = getStoredAuthConfig();
    setAuthUiState({
      connected: false,
      apiStatus: "offline",
      credentials: config?.client_id ? "salvas localmente" : "nao salvas",
      nextStep: "subir API de autenticacao"
    });
  }
}

function bindAuthForm() {
  document.getElementById("spotify-auth-form").addEventListener("submit", async (event) => {
    event.preventDefault();

    const payload = {
      client_id: document.getElementById("spotify-client-id").value.trim(),
      redirect_uri: document.getElementById("spotify-redirect-uri").value.trim(),
      scopes: document.getElementById("spotify-scopes").value.trim()
    };

    localStorage.setItem("spotify_auth_config", JSON.stringify(payload));

    try {
      await postJson("/auth/config", payload);
      const login = await postJson("/auth/login-url", payload);

      setAuthUiState({
        connected: false,
        apiStatus: "online",
        credentials: "salvas na API",
        nextStep: "autorizar no Spotify"
      });

      if (login?.url) {
        window.location.href = login.url;
      }
    } catch {
      setAuthUiState({
        connected: false,
        apiStatus: "offline",
        credentials: "salvas localmente",
        nextStep: "subir API de autenticacao"
      });
    }
  });

  document.getElementById("clear-auth-config").addEventListener("click", () => {
    localStorage.removeItem("spotify_auth_config");
    loadAuthForm();
  });
}

async function renderDashboard() {
  const overview = await fetchJson("/dashboard/overview", fallbackData.overview);
  const monthly = await fetchJson("/dashboard/monthly-evolution", fallbackData.monthly);
  const playsByDay = await fetchJson("/dashboard/plays-by-day", fallbackData.playsByDay);
  const playsByHour = await fetchJson("/dashboard/plays-by-hour", fallbackData.playsByHour);
  const topArtists = await fetchJson("/dashboard/top-artists", fallbackData.topArtists);
  const topAlbums = await fetchJson("/dashboard/top-albums", fallbackData.topAlbums);
  const savedTracks = await fetchJson("/dashboard/library/saved-tracks", fallbackData.savedTracks);
  const libraryArtists = await fetchJson("/dashboard/library/top-artists", fallbackData.libraryArtists);
  rankingsData = {
    short_term: await fetchJson("/dashboard/rankings/short_term", fallbackData.rankings.short_term),
    medium_term: await fetchJson("/dashboard/rankings/medium_term", fallbackData.rankings.medium_term),
    long_term: await fetchJson("/dashboard/rankings/long_term", fallbackData.rankings.long_term)
  };

  renderMetricCards(overview);
  renderDonut(overview);
  renderBarChart("monthly-chart", monthly, "plays");
  renderBarChart("plays-day-chart", playsByDay, "plays");
  renderHourGrid(playsByHour);
  renderRankList("top-artists-list", topArtists);
  renderRankList("top-albums-list", topAlbums);
  renderSavedTracks(savedTracks);
  renderRankList("library-artists-list", libraryArtists, "");
  renderRankings();
}

function bindNavigation() {
  const titles = {
    overview: "Overview",
    history: "Historico",
    library: "Biblioteca",
    rankings: "Rankings",
    account: "Conta"
  };

  document.querySelectorAll(".nav-tab").forEach((button) => {
    button.addEventListener("click", () => {
      const view = button.dataset.view;
      document.querySelectorAll(".nav-tab").forEach((tab) => tab.classList.remove("active"));
      document.querySelectorAll(".view").forEach((section) => section.classList.remove("active"));
      button.classList.add("active");
      document.getElementById(view).classList.add("active");
      document.getElementById("page-title").textContent = titles[view];
    });
  });

  document.querySelectorAll(".range-tab").forEach((button) => {
    button.addEventListener("click", () => {
      activeRange = button.dataset.range;
      document.querySelectorAll(".range-tab").forEach((tab) => tab.classList.remove("active"));
      button.classList.add("active");
      renderRankings();
    });
  });
}

bindNavigation();
bindAuthForm();
loadAuthForm();
checkAuthStatus();
renderDashboard();
