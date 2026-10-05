const PORT = process.env.CDP_PORT || 9333;
const TARGET = process.env.TARGET || '';

const list = async () => (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json();

const pick = async () => {
  const ts = (await list()).filter((t) => t.type === 'page');
  if (!ts.length) throw new Error('no page targets');
  if (!TARGET) {
    if (ts.length > 1) console.error('multiple targets, using first: ' + ts.map((t) => t.url).join(' , '));
    return ts[0];
  }
  const t = ts.find((x) => x.url.includes(TARGET) || x.title.includes(TARGET));
  if (!t) throw new Error('no target matches ' + TARGET + ' :: ' + ts.map((x) => x.url).join(' , '));
  return t;
};

const connect = async (url) => {
  const ws = new WebSocket(url);
  await new Promise((r, j) => { ws.addEventListener('open', r, { once: true }); ws.addEventListener('error', j, { once: true }); });
  let id = 0;
  const pending = new Map();
  const events = [];
  ws.addEventListener('message', (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) {
      const { res, rej } = pending.get(msg.id);
      pending.delete(msg.id);
      msg.error ? rej(new Error(JSON.stringify(msg.error))) : res(msg.result);
    } else if (msg.method) {
      events.push(msg);
    }
  });
  const waitFor = async (method, ms = 8000) => {
    const until = Date.now() + ms;
    for (;;) {
      const hit = events.find((e) => e.method === method);
      if (hit) return hit;
      if (Date.now() > until) throw new Error('timeout waiting for ' + method);
      await sleep(120);
    }
  };
  const send = (method, params = {}) =>
    new Promise((res, rej) => {
      const n = ++id;
      pending.set(n, { res, rej });
      ws.send(JSON.stringify({ id: n, method, params }));
    });
  return { ws, send, waitFor };
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const main = async () => {
  const [cmd, ...rest] = process.argv.slice(2);
  const t = await pick();
  const { ws, send, waitFor } = await connect(t.webSocketDebuggerUrl);
  await send('Runtime.enable');
  try {
    if (cmd === 'eval') {
      const expr = rest[0];
      const r = await send('Runtime.evaluate', {
        expression: `(async()=>{${expr}})()`,
        awaitPromise: true,
        returnByValue: true,
      });
      if (r.exceptionDetails) console.log('EXC: ' + JSON.stringify(r.exceptionDetails).slice(0, 800));
      else console.log(typeof r.result.value === 'string' ? r.result.value : JSON.stringify(r.result.value));
    } else if (cmd === 'goto') {
      await send('Page.enable');
      await send('Page.navigate', { url: rest[0] });
      console.log('navigated');
    } else if (cmd === 'reload') {
      await send('Page.enable');
      await send('Page.reload', { ignoreCache: true });
      console.log('reloaded');
    } else if (cmd === 'front') {
      await send('Page.enable');
      await send('Page.bringToFront');
      console.log('fronted');
    } else if (cmd === 'click') {
      const { x, y } = JSON.parse(rest[0]);
      await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y });
      await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1, buttons: 1 });
      await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
      console.log(`clicked ${x},${y}`);
    } else if (cmd === 'type') {
      await send('Input.insertText', { text: rest[0] });
      console.log('typed');
    } else if (cmd === 'keys') {
      for (const k of rest[0].split(',')) {
        const code = k.trim();
        const key = { Enter: 'Enter', Tab: 'Tab', Esc: 'Escape', Backspace: 'Backspace' }[code] || code;
        await send('Input.dispatchKeyEvent', { type: 'keyDown', key, code: key === ' ' ? 'Space' : key });
        await send('Input.dispatchKeyEvent', { type: 'keyUp', key, code: key === ' ' ? 'Space' : key });
      }
      console.log('keys sent');
    } else if (cmd === 'upload') {
      const { selector, files } = JSON.parse(rest[0]);
      const { root } = await send('DOM.getDocument', {});
      const { nodeId } = await send('DOM.querySelector', { nodeId: root.nodeId, selector });
      if (!nodeId) throw new Error('no node for ' + selector);
      await send('DOM.setFileInputFiles', { files, nodeId });
      console.log('files set: ' + files.length);
    } else if (cmd === 'shot') {
      await send('Page.enable');
      const r = await send('Page.captureScreenshot', { format: 'png' });
      const { writeFileSync } = await import('node:fs');
      writeFileSync(rest[0], Buffer.from(r.data, 'base64'));
      console.log('shot ' + rest[0]);
    } else if (cmd === 'drop') {
      const { x, y, files } = JSON.parse(rest[0]);
      await send('Page.enable');
      await send('Page.setInterceptFileChooserDialog', { enabled: true });
      await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y });
      await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1, buttons: 1 });
      await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
      const ev = await waitFor('Page.fileChooserOpened', 8000);
      await send('DOM.setFileInputFiles', { files, backendNodeId: ev.params.backendNodeId });
      console.log('dropped ' + files.length + ' file(s), mode=' + ev.params.mode);
    } else if (cmd === 'cap') {
      const { x, y, files, sel } = JSON.parse(rest[0]);
      await send('Runtime.enable');
      await send('Runtime.evaluate', {
        expression: `(()=>{try{window.__probe=[];if(!window.__patched){window.__patched=1;HTMLInputElement.prototype.click=function(){window.__probe.push('click accept='+this.accept+' multi='+this.multiple);window.__cap=this;};if(window.showOpenFilePicker){window.showOpenFilePicker=function(){window.__probe.push('showOpenFilePicker');return Promise.reject(new Error('captured'));};}}return 'patched';}catch(e){return 'ERR '+e.message}})();`,
      });
      await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x, y });
      await send('Input.dispatchMouseEvent', { type: 'mousePressed', x, y, button: 'left', clickCount: 1, buttons: 1 });
      await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x, y, button: 'left', clickCount: 1 });
      await sleep(1500);
      const probe = await send('Runtime.evaluate', { expression: 'JSON.stringify({probe:window.__probe,cap:!!window.__cap})', returnByValue: true });
      if (sel) {
        await send('Runtime.evaluate', { expression: `window.__cap=document.querySelector(${JSON.stringify(sel)})` });
      }
      const has = await send('Runtime.evaluate', { expression: '!!window.__cap', returnByValue: true });
      if (!has.result.value) return console.log('NO INPUT ' + probe.result.value);
      const { result } = await send('Runtime.evaluate', { expression: 'window.__cap' });
      const { nodeId } = await send('DOM.requestNode', { objectId: result.objectId });
      await send('DOM.setFileInputFiles', { files, nodeId });
      await send('Runtime.evaluate', { expression: `window.__cap.dispatchEvent(new Event('change',{bubbles:true}));window.__cap.dispatchEvent(new Event('input',{bubbles:true}));` });
      console.log('OK files=' + files.length + ' probe=' + probe.result.value);
    } else if (cmd === 'setfiles') {
      const { expr, files } = JSON.parse(rest[0]);
      await send('Runtime.enable');
      await send('DOM.enable');
      const { result } = await send('Runtime.evaluate', { expression: expr });
      if (result.subtype === 'null' || result.subtype === 'undefined' || !result.objectId) {
        return console.log('NO NODE ' + JSON.stringify(result).slice(0, 200));
      }
      await send('DOM.getDocument', { depth: -1, pierce: true });
      const rn = await send('DOM.requestNode', { objectId: result.objectId });
      console.log('DBG eval=' + JSON.stringify(result).slice(0, 200) + ' reqNode=' + JSON.stringify(rn));
      const nodeId = rn.nodeId;
      if (!nodeId) return console.log('NO NODEID');
      await send('DOM.setFileInputFiles', { files, nodeId });
      const r2 = await send('Runtime.callFunctionOn', {
        objectId: result.objectId,
        functionDeclaration: `function(){this.dispatchEvent(new Event('input',{bubbles:true}));this.dispatchEvent(new Event('change',{bubbles:true}));return this.files.length;}`,
        returnByValue: true,
      });
      console.log('SET files=' + files.length + ' inputNowHas=' + r2.result.value);
    } else if (cmd === 'drag') {
      const { from, to, steps = 25 } = JSON.parse(rest[0]);
      const move = (x, y, type) =>
        send('Input.dispatchMouseEvent', {
          type,
          x,
          y,
          button: type === 'mouseReleased' ? 'none' : 'left',
          clickCount: 1,
          buttons: type === 'mouseReleased' ? 0 : 1,
        });
      await move(from.x, from.y, 'mouseMoved');
      await move(from.x, from.y, 'mousePressed');
      for (let i = 1; i <= 6; i++) {
        await sleep(60);
        await move(from.x + ((to.x - from.x) * i) / 6, from.y + ((to.y - from.y) * i) / 6, 'mouseMoved');
      }
      await sleep(120);
      await move(to.x, to.y, 'mouseMoved');
      await sleep(160);
      await move(to.x, to.y, 'mouseReleased');
      console.log('dragged');
    } else if (cmd === 'scroll') {
      const r = await send('Runtime.evaluate', {
        expression: `(()=>{const el=document.querySelector(${JSON.stringify(rest[0])});if(!el)return 'nf';el.scrollIntoView({behavior:'instant',block:'center'});return 'y='+Math.round(window.scrollY)})()`,
        returnByValue: true,
      });
      console.log(r.result.value);
    } else if (cmd === 'sleep') {
      await sleep(Number(rest[0]));
      console.log('slept');
    } else {
      throw new Error('unknown cmd ' + cmd);
    }
  } finally {
    ws.close();
  }
};

main().catch((e) => { console.error('ERR ' + e.message); process.exit(1); });
