const app = document.getElementById('app');
const closeButton = document.getElementById('closeButton');
const refreshButton = document.getElementById('refreshButton');

function postNui(eventName) {
    fetch(`https://yg_playerpanel/${eventName}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    }).catch(() => {});
}

function closePanel() {
    app.classList.add('hidden');
    app.setAttribute('aria-hidden', 'true');
    postNui('close');
}

function updateData(data) {
    if (!data) return;
    document.getElementById('playerName').textContent = data.name || 'Nieznany gracz';
    document.getElementById('playerId').textContent = data.id ?? '--';
    document.getElementById('playerPing').textContent = data.ping ?? '--';
    document.getElementById('playerCount').textContent = data.online ?? '--';
    document.getElementById('maxPlayers').textContent = ` / ${data.maxPlayers ?? '--'}`;
}

window.addEventListener('message', (event) => {
    const message = event.data || {};
    if (message.action === 'open') {
        app.classList.remove('hidden');
        app.setAttribute('aria-hidden', 'false');
    } else if (message.action === 'close') {
        app.classList.add('hidden');
        app.setAttribute('aria-hidden', 'true');
    } else if (message.action === 'update') {
        updateData(message.data);
    }
});

closeButton.addEventListener('click', closePanel);
refreshButton.addEventListener('click', () => postNui('refresh'));
document.getElementById('casesButton').addEventListener('click', () => postNui('openCases'));

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !app.classList.contains('hidden')) {
        closePanel();
    }
});
