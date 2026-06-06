#!/usr/bin/env node
// would-read-md.js — fetch today's Gmail inbox emails, print context to stdout
// Usage: node would-read-md.js | node would-update-md.js
// Env: GMAIL_CLIENT_ID, GMAIL_CLIENT_SECRET, GMAIL_REFRESH_TOKEN
// Optional: GMAIL_QUERY (override default query), GMAIL_MAX_RESULTS (default 20)

const CLIENT_ID     = process.env.GMAIL_CLIENT_ID;
const CLIENT_SECRET = process.env.GMAIL_CLIENT_SECRET;
const REFRESH_TOKEN = process.env.GMAIL_REFRESH_TOKEN;
const MAX_RESULTS   = parseInt(process.env.GMAIL_MAX_RESULTS || '20', 10);

async function refreshAccessToken() {
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id:     CLIENT_ID,
      client_secret: CLIENT_SECRET,
      refresh_token: REFRESH_TOKEN,
      grant_type:    'refresh_token'
    })
  });
  if (!res.ok) throw new Error(`Token refresh failed: ${res.status} ${await res.text()}`);
  return (await res.json()).access_token;
}

async function gmailGet(token, path) {
  const res = await fetch(`https://gmail.googleapis.com/gmail/v1/users/me/${path}`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  if (!res.ok) throw new Error(`Gmail GET ${path} failed: ${res.status} ${await res.text()}`);
  return res.json();
}

function todayQuery() {
  const d = new Date();
  const after = `${d.getFullYear()}/${String(d.getMonth() + 1).padStart(2, '0')}/${String(d.getDate()).padStart(2, '0')}`;
  return process.env.GMAIL_QUERY || `in:inbox after:${after} -from:me`;
}

async function main() {
  if (!CLIENT_ID || !CLIENT_SECRET || !REFRESH_TOKEN) {
    throw new Error('GMAIL_CLIENT_ID, GMAIL_CLIENT_SECRET, GMAIL_REFRESH_TOKEN required');
  }

  const token = await refreshAccessToken();

  const q = todayQuery();
  const list = await gmailGet(token, `messages?q=${encodeURIComponent(q)}&maxResults=${MAX_RESULTS}`);
  const messages = list.messages || [];

  if (messages.length === 0) {
    console.error('No emails found');
    process.exit(1);
  }

  const items = [];
  for (const msg of messages) {
    const full = await gmailGet(
      token,
      `messages/${msg.id}?format=metadata&metadataHeaders=From&metadataHeaders=Subject&metadataHeaders=Date`
    );
    const headers = full.payload?.headers || [];
    const get = name => headers.find(h => h.name.toLowerCase() === name.toLowerCase())?.value || '';
    items.push({ from: get('From'), subject: get('Subject'), date: get('Date') });
  }

  const context = items
    .map(i => `From: ${i.from} | Subject: ${i.subject} | Date: ${i.date}`)
    .join('\n');

  process.stdout.write(context);
}

main().catch(e => { console.error('❌', e.message); process.exit(1); });
