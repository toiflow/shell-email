#!/usr/bin/env node
// get-gmail-token.js — one-time script to get Gmail OAuth refresh token
// Run once locally, copy the 3 gh secret set commands, then delete this file.

import * as http from 'http';
import * as url from 'url';

const CLIENT_ID     = process.env.GMAIL_CLIENT_ID     || '';
const CLIENT_SECRET = process.env.GMAIL_CLIENT_SECRET || '';
const SCOPE         = 'https://www.googleapis.com/auth/gmail.readonly';

if (!CLIENT_ID || !CLIENT_SECRET) {
  console.error('Set GMAIL_CLIENT_ID and GMAIL_CLIENT_SECRET env vars first');
  process.exit(1);
}

const server = http.createServer();
server.listen(0, '127.0.0.1', () => {
  const { port } = server.address();
  const REDIRECT_URI = `http://localhost:${port}`;

  const authUrl = `https://accounts.google.com/o/oauth2/v2/auth?` +
    `client_id=${encodeURIComponent(CLIENT_ID)}` +
    `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}` +
    `&response_type=code` +
    `&scope=${encodeURIComponent(SCOPE)}` +
    `&access_type=offline` +
    `&prompt=consent`;

  console.log('\nOpen this URL in a browser:\n');
  console.log(authUrl);
  console.log('\nWaiting for redirect...\n');

  server.on('request', async (req, res) => {
    const code = new url.URL(req.url, REDIRECT_URI).searchParams.get('code');
    res.end('<html><body><h2>Done — return to terminal.</h2></body></html>');
    server.close();

    if (!code) { console.error('No code in redirect'); process.exit(1); }

    const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        code,
        client_id:     CLIENT_ID,
        client_secret: CLIENT_SECRET,
        redirect_uri:  REDIRECT_URI,
        grant_type:    'authorization_code'
      })
    });
    const data = await tokenRes.json();
    if (!tokenRes.ok) { console.error('❌ Token exchange failed:', data); process.exit(1); }

    console.log('✅ Run these 3 commands:\n');
    console.log(`gh secret set GMAIL_CLIENT_ID     --org toiflow --visibility all --body "${CLIENT_ID}"`);
    console.log(`gh secret set GMAIL_CLIENT_SECRET --org toiflow --visibility all --body "${CLIENT_SECRET}"`);
    console.log(`gh secret set GMAIL_REFRESH_TOKEN --org toiflow --visibility all --body "${data.refresh_token}"`);
    console.log('\nThen delete get-gmail-token.js');
  });
});
