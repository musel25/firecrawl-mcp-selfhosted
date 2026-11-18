import { spawn } from 'node:child_process';

const tool = process.argv[2] === 'scrape' ? 'firecrawl_scrape' : 'firecrawl_search';
const args = tool === 'firecrawl_scrape'
  ? { url: 'https://example.com', formats: ['markdown'] }
  : { query: 'software engineer new graduate jobs', limit: 3 };
const child = spawn('ssh', ['-T', 'my-vps', '/home/ubuntu/firecrawl-mcp-selfhosted/scripts/mcp-stdio.sh'], {
  stdio: ['pipe', 'pipe', 'inherit'],
});
const send = (message) => child.stdin.write(`${JSON.stringify(message)}\n`);
let buffer = '';
let finished = false;
const timeout = setTimeout(() => {
  console.error('MCP tool call timed out');
  child.kill();
  process.exitCode = 1;
}, 45000);
child.stdout.on('data', (chunk) => {
  buffer += chunk.toString();
  let end;
  while ((end = buffer.indexOf('\n')) >= 0) {
    const line = buffer.slice(0, end);
    buffer = buffer.slice(end + 1);
    let message;
    try { message = JSON.parse(line); } catch { continue; }
    if (message.id === 1) {
      send({ jsonrpc: '2.0', method: 'notifications/initialized' });
      send({ jsonrpc: '2.0', id: 2, method: 'tools/call', params: { name: tool, arguments: args } });
    }
    if (message.id === 2) {
      finished = true;
      clearTimeout(timeout);
      const result = message.result;
      const content = JSON.stringify(result?.content ?? []);
      console.log(JSON.stringify({ tool, isError: result?.isError ?? false, contentLength: content.length, excerpt: content.slice(0, 500) }));
      if (message.error || result?.isError || content.length < 50) process.exitCode = 1;
      child.stdin.end();
      child.kill();
    }
  }
});
child.on('exit', (code) => {
  clearTimeout(timeout);
  if (!finished) {
    console.error(`MCP process exited before tool result: ${code}`);
    process.exitCode = 1;
  }
});
send({ jsonrpc: '2.0', id: 1, method: 'initialize', params: {
  protocolVersion: '2025-03-26', capabilities: {}, clientInfo: { name: 'smoke', version: '0.1' },
} });
