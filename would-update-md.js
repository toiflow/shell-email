#!/usr/bin/env node
// would-update-md.js — local-use only: stdin email context → Ollama → GitHub API
// Usage: node would-read-md.js | node would-update-md.js
// In CI: workflow calls must-update-access.yml (Ollama) + would-update-content.js (GitHub write)

const OLLAMA_URL   = process.env.OLLAMA_URL   || 'https://local.toigroup.co.nz';
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || 'qwen2.5:7b';
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const GITHUB_OWNER = 'toiflow';
const GITHUB_REPO  = 'ts-inbox';
const ANCHOR = '####### <!-- ANCHOR MARKER - ADD ALL NEW ENTRIES DIRECTLY BELOW THIS LINE, NEVER DELETE OR EDIT PREVIOUS ENTRIES-->';

async function readStdin() {
  return new Promise(resolve => {
    let data = '';
    process.stdin.on('data', c => data += c);
    process.stdin.on('end', () => resolve(data.trim()));
  });
}

function nzTimestamp() {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Pacific/Auckland',
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', hour12: false
  }).formatToParts(new Date());
  const get = t => parts.find(p => p.type === t).value;
  return `${get('year')}-${get('month')}-${get('day')} ${get('hour')}:${get('minute')}`;
}

async function callOllama(prompt) {
  const res = await fetch(`${OLLAMA_URL}/api/generate`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-secret': process.env.OLLAMA_SECRET },
    body: JSON.stringify({ model: OLLAMA_MODEL, prompt, stream: false }),
    signal: AbortSignal.timeout(180_000)
  });
  if (!res.ok) throw new Error(`Ollama ${res.status}: ${await res.text()}`);
  return (await res.json()).response.trim();
}

async function githubGet(path) {
  const res = await fetch(
    `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/contents/${path}`,
    { headers: { 'Authorization': `Bearer ${GITHUB_TOKEN}`, 'Accept': 'application/vnd.github+json' } }
  );
  if (!res.ok) throw new Error(`GitHub GET ${path} failed: ${res.status}`);
  const data = await res.json();
  return { sha: data.sha, content: Buffer.from(data.content, 'base64').toString('utf8') };
}

async function githubPut(path, sha, content, message) {
  const res = await fetch(
    `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/contents/${path}`,
    {
      method: 'PUT',
      headers: { 'Authorization': `Bearer ${GITHUB_TOKEN}`, 'Accept': 'application/vnd.github+json', 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message, sha,
        content: Buffer.from(content).toString('base64'),
        committer: { name: 'shell-email', email: 'jayreck996@gmail.com' }
      })
    }
  );
  if (!res.ok) throw new Error(`GitHub PUT ${path} failed: ${res.status} ${await res.text()}`);
}

function insertEntry(fileContent, entry) {
  const idx = fileContent.indexOf(ANCHOR);
  if (idx === -1) throw new Error('Anchor marker not found');
  const at = idx + ANCHOR.length;
  return fileContent.slice(0, at) + '\n' + entry + '\n' + fileContent.slice(at);
}

async function main() {
  if (!GITHUB_TOKEN) throw new Error('GITHUB_TOKEN not set');

  const emails = await readStdin();
  if (!emails) throw new Error('No email context on stdin — pipe output of would-read-md.js');

  const emailCount = (emails.match(/^From:/gm) || []).length;
  const ts = nzTimestamp();
  console.log(`📅 ${ts} | ${emailCount} emails`);

  console.log('\n🤖 Ollama → ISSUE analysis...');
  const issueAnalysis = await callOllama(
    `You are an executive assistant reviewing today's inbox. Based on the emails below, identify:\n` +
    `- Any urgent or time-sensitive items\n` +
    `- Action items or decisions required\n` +
    `- Any risks, blockers, or problems flagged\n\n` +
    `Format as 3-5 short bullet points using "- " prefix. One line per bullet. No intro sentence.\n\n` +
    emails
  );
  console.log(issueAnalysis);

  const issueFile = await githubGet('would/CONTENT-ISSUE-V1.md');
  await githubPut(
    'would/CONTENT-ISSUE-V1.md', issueFile.sha,
    insertEntry(issueFile.content, `## ISSUE:EMAIL ${ts}\n${issueAnalysis}`),
    `would-update: issue ${ts}`
  );
  console.log('✅ would/CONTENT-ISSUE-V1.md updated');

  console.log('\n🤖 Ollama → ASSET analysis...');
  const assetAnalysis = await callOllama(
    `You are an executive assistant reviewing today's inbox. Based on the emails below, summarize:\n` +
    `- Key information, updates, or decisions received\n` +
    `- Any opportunities or follow-ups worth noting\n` +
    `- Overall tone and priority of the inbox\n\n` +
    `Format as 3-5 short bullet points using "- " prefix. One line per bullet. No intro sentence.\n\n` +
    emails
  );
  console.log(assetAnalysis);

  const assetFile = await githubGet('would/CONTENT-ASSET-V1.md');
  await githubPut(
    'would/CONTENT-ASSET-V1.md', assetFile.sha,
    insertEntry(assetFile.content, `## ASSET:EMAIL ${ts}\n${assetAnalysis}`),
    `would-update: asset ${ts}`
  );
  console.log('✅ would/CONTENT-ASSET-V1.md updated');

  console.log('\n✅ Done');
}

main().catch(e => { console.error('❌', e.message); process.exit(1); });
